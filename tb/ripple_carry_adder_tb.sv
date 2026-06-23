module ripple_carry_adder_tb;
localparam WIDTH = 32;

logic [WIDTH - 1:0] a ,b, sum;
logic [WIDTH:0] exp_sum;
logic cin, cout;

ripple_carry_adder #(.WIDTH(WIDTH)) dut(
    .a(a),
    .b(b),
    .sum(sum),
    .cout(cout),
    .cin(cin)
    );

task check();
    exp_sum = a + b + cin;
    #5;
    if ({cout,sum} !== exp_sum)
        $error("FAIL a:%h | b:%h | cin:%b | sum:%h | exp_sum: %h", a,b,cin,sum,exp_sum[31:0]);
    else
        $display("PASS a:%h | b:%h | cin:%b | sum:%h | exp_sum: %h", a,b,cin,sum,exp_sum[31:0]);
endtask

initial begin
    $dumpfile("dump/ripple_dump.vcd");
    $dumpvars(0, ripple_carry_adder_tb);
    a = 32'h00000000; b = 32'h00000000; cin = 1'b0; #10; check();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; cin = 1'b0; #10; check();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; cin = 1'b1; #10; check();

    for(int i = 0; i < 50; i++) begin
        a = $urandom;
        b = $urandom;
        cin = $urandom_range(0, 1);
        #10;
        check();
    end
end
endmodule
