module two_compliment_subtractor_tb;
localparam WIDTH = 32;

logic [WIDTH - 1:0] a,b,exp_difference,difference;

two_compliment_subtractor #(.WIDTH(WIDTH)) dut(

    .a(a),
    .b(b),
    .difference(difference)
);

task check();
    exp_difference = a - b;
    #5
    if(exp_difference !== difference)
        $error("FAIL a = %h | b = %h | difference = %h | exp_difference = %h", a, b, exp_difference, difference);
    else
        $display("PASS a = %h | b = %h | difference = %h | exp_difference = %h", a, b, exp_difference, difference);
endtask

initial begin
    $dumpfile("dump/subtractor_dump.vcd");
    $dumpvars(0, two_compliment_subtractor_tb);
    a = 32'h00000000; b = 32'h00000000;  #10; check(); // 0 - 0 = 0
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF;  #10; check(); // MAX - MAX = 0
    a = 32'h00000000; b = 32'h00000001;  #10; check(); // underflow wrap: 0 - 1 = 0xFFFFFFFF
    a = 32'h00000000; b = 32'hFFFFFFFF;  #10; check(); // max underflow
    a = 32'hFFFFFFFF; b = 32'h00000000;  #10; check(); // MAX - 0 = MAX
    a = 32'h00000001; b = 32'h00000001;  #10; check(); // non-zero inputs, zero result
    a = 32'h80000000; b = 32'h00000001;  #10; check(); // signed min - 1

    for(int i = 0; i < 50; i++) begin
        a = $urandom;
        b = $urandom;
        
        #10;
        check();
    end
end
endmodule