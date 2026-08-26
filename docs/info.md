## How it works

This project is a 32-bit ALU supporting nine operations, selected by a
4-bit opcode: ADD, SUB, AND, OR, XOR, NOR, logical shift left (LSL),
logical shift right (LSR), and arithmetic shift right (ASR). The
add/subtract path also produces zero, sign, overflow, and carry flags.

The ALU core itself (`alu.sv`, plus `add_subtract_unit.sv`,
`logic_unit.sv`, `shift_unit.sv`, `decoder.sv`, and `full_adder.sv`) is a
plain combinational 32-bit datapath. Tiny Tapeout only exposes 24 user
I/O pins, far fewer than the 68 input bits (`a`, `b`, `opcode`) and 36
output bits (`result`, flags) the ALU needs, so `tt_um_armin_pourmo_alu32.sv`
wraps it in a small byte-addressable register file that loads operands
and reads back results one byte per clock cycle.

### Register map (address on `uio[3:0]`)

| Address | Register       | Access |
|---------|----------------|--------|
| 0x0-0x3 | A[7:0]..A[31:24]   | write |
| 0x4-0x7 | B[7:0]..B[31:24]   | write |
| 0x8     | opcode[3:0]        | write (also triggers compute) |
| 0x9-0xC | result[7:0]..[31:24] | read |
| 0xD     | flags `{carry, overflow, sign, zero}` in bits [3:0] | read |

Opcodes: `0000`=AND, `0001`=OR, `0010`=XOR, `0011`=NOR, `0100`=ADD,
`0101`=SUB, `0110`=LSL, `0111`=LSR, `1000`=ASR. For shifts, the shift
amount is `B[4:0]`.

## How to test

1. Hold `rst_n` low for a few cycles, then release it.
2. Write the 4 bytes of operand A to addresses `0x0`-`0x3`: drive
   `ui_in` with the data byte and `uio_in` with `{3'b0, 1'b1 (write
   enable), address[3:0]}`, then pulse `clk`.
3. Write the 4 bytes of operand B to addresses `0x4`-`0x7` the same way.
4. Write the opcode nibble to address `0x8`. This same write latches the
   ALU's result and flags into their output registers.
5. Read back the result by setting `uio_in[3:0]` to `0x9`-`0xC` (write
   enable low) and sampling `uo_out` each cycle.
6. Read the flags byte at address `0xD` the same way.

One full operation takes 14 bus cycles. See `test/test.py` for a
runnable cocotb reference implementation of this sequence.

## External hardware

None - this project only needs the standard Tiny Tapeout PMOD/demo
board GPIO to drive `ui_in`/`uio_in` and read `uo_out`.
