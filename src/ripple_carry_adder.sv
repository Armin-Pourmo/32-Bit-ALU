module ripple_carry_adder #(parameter WIDTH = 32) (
    input logic [WIDTH - 1:0] a, b,
    input logic cin,
    output logic [WIDTH - 1:0] sum,
    output logic cout
);

logic [WIDTH:0] carry;
assign carry[0] = cin;
assign cout = carry[WIDTH];

genvar i;
generate
    for (i = 0; i < WIDTH; i++) begin : adder_chain
        full_adder fa (
            .a(a[i]),
            .b(b[i]),
            .cin (carry[i]),
            .sum(sum[i]),
            .cout(carry[i+1])
        );
    end

endgenerate
endmodule