/*
 * Copyright (c) 2026 Armin-Pourmo
 * SPDX-License-Identifier: Apache-2.0
 *
 * Tiny Tapeout wrapper for the 32-bit ALU (alu.sv).
 *
 * The ALU needs 68 input bits (a, b, opcode) and 36 output bits
 * (result, flags) but Tiny Tapeout only exposes 24 user pins, so this
 * wrapper exposes the ALU through a byte-addressable register file
 * instead of driving it directly:
 *
 *   ui_in[7:0]   = write-data bus
 *   uio_in[3:0]  = register address
 *   uio_in[4]    = write enable (registers ui_in at [addr] on this clk edge)
 *   uio_in[7:5]  = unused, tie low
 *   uo_out[7:0]  = read-data bus, combinationally reflects reg[addr]
 *
 * Register map (byte address):
 *   0x0-0x3  A[7:0]..A[31:24]        write
 *   0x4-0x7  B[7:0]..B[31:24]        write
 *   0x8      opcode[3:0]             write - also latches result+flags
 *   0x9-0xC  result[7:0]..[31:24]    read
 *   0xD      flags {carry,overflow,sign,zero} in bits [3:0]  read
 *
 * To run one operation: write A (4 bytes), write B (4 bytes), write
 * opcode (1 byte - this also triggers the compute/latch), then read
 * result (4 bytes) and flags (1 byte). 14 bus cycles total.
 */

`default_nettype none

module tt_um_armin_pourmo_alu32 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output logic [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    localparam WIDTH = 32;

    // ── Register file ───────────────────────────────────────────────
    logic [WIDTH-1:0] a_reg, b_reg, result_reg;
    logic [3:0]        opcode_reg;
    logic [3:0]        flags_reg; // {carry, overflow, sign, zero}

    localparam ADDR_A0 = 4'h0, ADDR_A3 = 4'h3;
    localparam ADDR_B0 = 4'h4, ADDR_B3 = 4'h7;
    localparam ADDR_OP = 4'h8;
    localparam ADDR_R0 = 4'h9, ADDR_R3 = 4'hC;
    localparam ADDR_FLAGS = 4'hD;

    wire        write_enable = uio_in[4];
    wire [3:0]  addr         = uio_in[3:0];

    // On the same cycle opcode is written, bypass the (still-stale)
    // registered opcode so the ALU computes with the incoming value and
    // result_reg captures the correct result in that same clock edge.
    wire [3:0] opcode_for_alu =
        (write_enable && addr == ADDR_OP) ? ui_in[3:0] : opcode_reg;

    logic [WIDTH-1:0] alu_result;
    logic             alu_zero, alu_sign, alu_overflow, alu_carry;

    alu #(.WIDTH(WIDTH)) alu_core (
        .a        (a_reg),
        .b        (b_reg),
        .opcode   (opcode_for_alu),
        .result   (alu_result),
        .zero     (alu_zero),
        .sign     (alu_sign),
        .overflow (alu_overflow),
        .carry    (alu_carry)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg      <= '0;
            b_reg      <= '0;
            opcode_reg <= '0;
            result_reg <= '0;
            flags_reg  <= '0;
        end else if (write_enable) begin
            case (addr)
                4'h0: a_reg[7:0]   <= ui_in;
                4'h1: a_reg[15:8]  <= ui_in;
                4'h2: a_reg[23:16] <= ui_in;
                4'h3: a_reg[31:24] <= ui_in;
                4'h4: b_reg[7:0]   <= ui_in;
                4'h5: b_reg[15:8]  <= ui_in;
                4'h6: b_reg[23:16] <= ui_in;
                4'h7: b_reg[31:24] <= ui_in;
                ADDR_OP: begin
                    opcode_reg <= ui_in[3:0];
                    result_reg <= alu_result;
                    flags_reg  <= {alu_carry, alu_overflow, alu_sign, alu_zero};
                end
                default: ; // 0x9-0xF are read-only
            endcase
        end
    end

    always_comb begin
        case (addr)
            4'h0: uo_out = a_reg[7:0];
            4'h1: uo_out = a_reg[15:8];
            4'h2: uo_out = a_reg[23:16];
            4'h3: uo_out = a_reg[31:24];
            4'h4: uo_out = b_reg[7:0];
            4'h5: uo_out = b_reg[15:8];
            4'h6: uo_out = b_reg[23:16];
            4'h7: uo_out = b_reg[31:24];
            ADDR_OP: uo_out = {4'b0, opcode_reg};
            4'h9: uo_out = result_reg[7:0];
            4'hA: uo_out = result_reg[15:8];
            4'hB: uo_out = result_reg[23:16];
            4'hC: uo_out = result_reg[31:24];
            ADDR_FLAGS: uo_out = {4'b0, flags_reg};
            default: uo_out = 8'h00;
        endcase
    end

    // uio is used only as an input bus (address + write-enable) here.
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    wire _unused = &{ena, 1'b0};

endmodule
