module add_subtract_unit_tb;
localparam WIDTH = 32;

logic [WIDTH - 1:0] a , b, sum, exp_sum,exp_diff;
logic sub,cout;

add_subtract_unit #(.WIDTH(WIDTH)) dut(
    .a(a),
    .b(b),
    .sum(sum),
    .sub(sub),
    .cout(cout)
);

task check_add(); 
    exp_sum = a + b;
    if(exp_sum === sum)
        $display("PASS_ADD a = %h | b = %h | sub = %h | exp_sum = %h | sum = %h",a,b,sub,exp_sum,sum);
    else
        $error("FAIL_ADD a = %h | b = %h | sub = %h | exp_sum = %h | sum = %h",a,b,sub,exp_sum,sum);
endtask

task check_sub(); 
    exp_diff = a - b;
    if(exp_diff === sum)
        $display("PASS_SUB a = %h | b = %h | sub = %h | exp_diff = %h | sum = %h",a,b,sub,exp_diff,sum);
    else
        $error("FAIL_SUB a = %h | b = %h | sub = %h | exp_diff = %h | sum = %h",a,b,sub,exp_diff,sum);
endtask

initial begin
    $dumpfile("dump/add_subtract_unit_dump.vcd");
    $dumpvars(0, add_subtract_unit_tb);
    a = 32'h00000000; b = 32'h00000000; sub = 1'b0; #10; check_add();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; sub = 1'b0; #10; check_add();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; sub = 1'b0; #10; check_add();

    for(int i = 0; i < 50; i++) begin
        a = $urandom;
        b = $urandom;
        sub = 0;
        #10;
        check_add();
    end

    a = 32'h00000000; b = 32'h00000000; sub = 1'b1; #10; check_sub();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; sub = 1'b1; #10; check_sub();
    a = 32'hFFFFFFFF; b = 32'hFFFFFFFF; sub = 1'b1; #10; check_sub();

    for(int i = 0; i < 50; i++) begin
        a = $urandom;
        b = $urandom;
        sub = 1;
        #10;
        check_sub();
    end
end
endmodule
