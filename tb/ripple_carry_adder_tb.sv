module ripple_carry_adder_tb;
localparam WIDTH = 32;

logic [WIDTH - 1:0] a ,b, sum, exp_sum;
logic cin, cout,exp_cout;

ripple_carry_adder #(.WIDTH(WIDTH)) dut(a,b,cin,sum,cout);

integer fh;
integer scan_result;
integer pass_count, fail_count, test_num;

initial begin
    
  $dumpfile("dump.vcd");
  $dumpvars(0, ripple_carry_adder_tb);
  
  // rest of code
    pass_count = 0;
    fail_count = 0;
    test_num = 0;

    fh = $fopen("../tb/ripple_carry_adder_tb.tv","r");
    if (fh==0)begin
        $display("ERROR: could not open vector file");
        $finish;
    end
    while (!$feof(fh)) begin
        scan_result = $fscanf(fh, "%b %b %b %b %b\n",
                                a,b,cin,exp_sum,exp_cout);

        if(scan_result != 5) continue;
        #10;
        
        test_num++;
        if(sum !== exp_sum || cout !== exp_cout) begin
            $display("FAIL test %0d | a=%b b=%b cin=%b | got sum=%b cout=%b | expected sum=%b cout=%b",
                        test_num,a,b,cin,sum,cout,exp_sum,exp_cout);
            fail_count++;
        end else begin
            $display("PASS test %0d | a=%b b=%b cin=%b = %b",
                        test_num,a,b,cin,sum);
            pass_count++;
        end
    end
    $fclose(fh);
    $display("--- %0d passed, %0d failed ---", pass_count, fail_count);
    $finish;
end

endmodule
