module alu #(parameter WIDTH = 32)(

    input logic [WIDTH-1:0]     a,b,
    input logic [3:0]           opcode,
    output logic [WIDTH-1:0]    result,
    output logic                zero,sign,overflow,carry

) ;

decoder #(.WIDTH(WIDTH)) decode(
    .opcode(opcode)
);

add_subtract_unit #(.WIDTH(WIDTH)) ALU_ADD(
    .a(a),
    .b(b),
)