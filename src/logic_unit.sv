module logic_unit #(parameter WIDTH = 32) (
    input logic [WIDTH - 1:0] a , b,
    output logic [WIDTH - 1:0] y_and, y_or, y_xor, y_nor
);

always_comb begin : logicUnits

    y_and = a & b;
    y_or = a | b;
    y_xor = a ^ b;
    y_nor = ~(a | b);
end

endmodule