module two_compliment_subtractor #(parameter WIDTH = 32)(
    input logic [WIDTH - 1:0] a , b,
    output logic [WIDTH - 1:0] difference
);

logic [WIDTH - 1:0] inverted, compliment;

always_comb begin : inverter
    
for(int i = 0; i < WIDTH; i++) begin
    inverted[i] = b[i] ^ 1;
    
end


end

ripple_carry_adder #(.WIDTH(WIDTH)) one_add(
    .a(32'b0),
    .b(inverted),
    .cin(1'b1),
    .sum(compliment),
    .cout()
);

ripple_carry_adder #(.WIDTH(WIDTH)) difference_getter(
    .a(a),
    .b(compliment),
    .cin(1'b0),
    .sum(difference)
);

endmodule






