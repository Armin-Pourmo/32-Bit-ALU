module ripple_carry_adder_tb;
localparam WIDTH = 32;

logic [WIDTH - 1:0] a ,b, sum, exp_sum;
logic cin, cout,exp_cout;

ripple_carry_adder #(.WIDTH(WIDTH)) dut(a,b,cin,sum,cout);

integer fh;
integer scan_result;
integer pass_count, fail_count, test_num;

initial begin

  $dumpfile("dump/ripple_dump.vcd");
  $dumpvars(0, ripple_carry_adder_tb);

  // rest of code
    pass_count = 0;
    fail_count = 0;
    test_num = 0;

    fh = $fopen("tb/ripple_carry_adder_tb.tv","r");
    if (fh==0)begin
        $display("ERROR: could not open vector file");
        $finish;
    end
    begin : read_loop
        string line;
        while (!$feof(fh)) begin
            if ($fgets(line, fh) == 0) break;
            if (line.substr(0,1) == "//") continue;
            scan_result = $sscanf(line, "%b %b %b %b %b", a, b, cin, exp_sum, exp_cout);
            if (scan_result != 5) continue;
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
    end : read_loop
    $fclose(fh);
    $display("--- %0d passed, %0d failed ---", pass_count, fail_count);
    $finish;
end

endmodule
