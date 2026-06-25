module logic_unit_tb;
    localparam WIDTH = 32;

    logic [WIDTH - 1:0] a, b, y_and, y_or, y_xor, y_nor;
    logic [WIDTH - 1:0] exp_and, exp_or, exp_xor, exp_nor;

    logic_unit #(.WIDTH(WIDTH)) dut(
        .a(a),
        .b(b),
        .y_and(y_and),
        .y_or(y_or),
        .y_xor(y_xor),
        .y_nor(y_nor)
    );

    initial begin
        $dumpfile("dump/logic_unit.vcd");
        $dumpvars(0,logic_unit_tb);
        // Test 1: All zeros
        a = 32'h00000000; b = 32'h00000000;
        #5;
        exp_and = a & b;
        exp_or = a | b;
        exp_xor = a ^ b;
        exp_nor = ~(a | b);
        
        assert(y_and === exp_and) else $error("AND failed: a=%h b=%h exp=%h got=%h", a, b, exp_and, y_and);
        assert(y_or === exp_or) else $error("OR failed: a=%h b=%h exp=%h got=%h", a, b, exp_or, y_or);
        assert(y_xor === exp_xor) else $error("XOR failed: a=%h b=%h exp=%h got=%h", a, b, exp_xor, y_xor);
        assert(y_nor === exp_nor) else $error("NOR failed: a=%h b=%h exp=%h got=%h", a, b, exp_nor, y_nor);
        $display("Test 1 (all zeros): PASS");

        // Test 2: All ones
        a = 32'hFFFFFFFF; b = 32'hFFFFFFFF;
        #5;
        exp_and = a & b;
        exp_or = a | b;
        exp_xor = a ^ b;
        exp_nor = ~(a | b);
        
        assert(y_and === exp_and) else $error("AND failed");
        assert(y_or === exp_or) else $error("OR failed");
        assert(y_xor === exp_xor) else $error("XOR failed");
        assert(y_nor === exp_nor) else $error("NOR failed");
        $display("Test 2 (all ones): PASS");

        // Test 3: Alternating pattern
        a = 32'hAAAAAAAA; b = 32'h55555555;
        #5;
        exp_and = a & b;
        exp_or = a | b;
        exp_xor = a ^ b;
        exp_nor = ~(a | b);
        
        assert(y_and === exp_and) else $error("AND failed");
        assert(y_or === exp_or) else $error("OR failed");
        assert(y_xor === exp_xor) else $error("XOR failed");
        assert(y_nor === exp_nor) else $error("NOR failed");
        $display("Test 3 (alternating): PASS");

        // Test 4: Random vector
        a = $urandom;
        b = $urandom;
        #5;
        exp_and = a & b;
        exp_or = a | b;
        exp_xor = a ^ b;
        exp_nor = ~(a | b);
        
        assert(y_and === exp_and) else $error("AND failed");
        assert(y_or === exp_or) else $error("OR failed");
        assert(y_xor === exp_xor) else $error("XOR failed");
        assert(y_nor === exp_nor) else $error("NOR failed");
        $display("Test 4 (random): PASS");

        $display("All logic_unit tests passed!");
        $finish;
    end
endmodule