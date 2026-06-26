`timescale 1ns/1ps
module vending_machine_tb();

reg clk, rst;
reg [1:0] in;
wire [1:0] change;
wire out;

vending_machine dut(
    .clk(clk),
    .rst(rst),
    .in(in),
    .change(change),
    .out(out)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    $dumpfile("vending_machine_tb.vcd");
    $dumpvars(0, vending_machine_tb);
end

initial begin
    $monitor("T=%0t | in=%0d Rs | out=%b | change=%0d Rs | state=%0d",
              $time, in*5, out, change*5, dut.ps);
end

initial begin
    // reset
    rst = 1;
    in  = 2'b00;
    #20;
    rst = 0;
    #10;

    // -------------------------------------------------------
    // TEST 1: Insert 5Rs + 5Rs = 10Rs ? out=1, change=0
    // -------------------------------------------------------
    $display("\n--- TEST 1: 5Rs + 5Rs ---");
    @(negedge clk); in = 2'b01;  // 5Rs ? go to S1
    @(negedge clk); in = 2'b01;  // 5Rs ? go to S2
    @(negedge clk); in = 2'b00;  // 0Rs ? out=0? change=10 (S2+cancel)
    #20;
    $display("Expected: S1 after 5Rs, S2 after 5+5Rs");
    $display("Note: item not dispensed yet - need to check S2 transitions");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 2: Insert 10Rs directly ? S2, no item yet
    // -------------------------------------------------------
    $display("\n--- TEST 2: 10Rs direct ? S2 ---");
    @(negedge clk); in = 2'b10;  // 10Rs ? go to S2
    @(negedge clk); in = 2'b01;  // 5Rs more ? out=1, change=0
    #20;
    $display("Expected: out=1, change=0 Rs");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 3: Insert 5Rs + 10Rs ? out=1, change=0 (S1+10Rs)
    // -------------------------------------------------------
    $display("\n--- TEST 3: 5Rs + 10Rs ---");
    @(negedge clk); in = 2'b01;  // 5Rs ? S1
    @(negedge clk); in = 2'b10;  // 10Rs ? out=1, change=0
    #20;
    $display("Expected: out=1, change=0 Rs");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 4: Insert 10Rs + 10Rs ? out=1, change=5Rs (S2+10Rs)
    // -------------------------------------------------------
    $display("\n--- TEST 4: 10Rs + 10Rs ---");
    @(negedge clk); in = 2'b10;  // 10Rs ? S2
    @(negedge clk); in = 2'b10;  // 10Rs ? out=1, change=5
    #20;
    $display("Expected: out=1, change=5 Rs");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 5: Insert 5Rs then cancel ? change=5Rs returned
    // -------------------------------------------------------
    $display("\n--- TEST 5: 5Rs then cancel ---");
    @(negedge clk); in = 2'b01;  // 5Rs ? S1
    @(negedge clk); in = 2'b00;  // cancel ? change=5Rs, out=0
    #20;
    $display("Expected: out=0, change=5 Rs");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 6: Insert 10Rs then cancel ? change=10Rs returned
    // -------------------------------------------------------
    $display("\n--- TEST 6: 10Rs then cancel ---");
    @(negedge clk); in = 2'b10;  // 10Rs ? S2
    @(negedge clk); in = 2'b00;  // cancel ? change=10Rs, out=0
    #20;
    $display("Expected: out=0, change=10 Rs");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 7: Insert 5Rs+5Rs then cancel ? change=10Rs
    // -------------------------------------------------------
    $display("\n--- TEST 7: 5Rs + 5Rs then cancel ---");
    @(negedge clk); in = 2'b01;  // 5Rs ? S1
    @(negedge clk); in = 2'b01;  // 5Rs ? S2
    @(negedge clk); in = 2'b00;  // cancel ? change=10Rs, out=0
    #20;
    $display("Expected: out=0, change=10 Rs");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 8: Insert 5Rs+5Rs+5Rs ? out=1, change=0
    // -------------------------------------------------------
    $display("\n--- TEST 8: 5Rs + 5Rs + 5Rs ---");
    @(negedge clk); in = 2'b01;  // 5Rs ? S1
    @(negedge clk); in = 2'b01;  // 5Rs ? S2
    @(negedge clk); in = 2'b01;  // 5Rs ? out=1, change=0
    #20;
    $display("Expected: out=1, change=0 Rs");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 9: No coin inserted ? stay S0
    // -------------------------------------------------------
    $display("\n--- TEST 9: No coin, stay S0 ---");
    @(negedge clk); in = 2'b00;
    @(negedge clk); in = 2'b00;
    @(negedge clk); in = 2'b00;
    #20;
    $display("Expected: out=0, change=0, stay S0");

    rst = 1; #10; rst = 0; in = 2'b00; #10;

    // -------------------------------------------------------
    // TEST 10: reset mid-transaction
    // -------------------------------------------------------
    $display("\n--- TEST 10: reset mid-transaction ---");
    @(negedge clk); in = 2'b01;  // 5Rs ? S1
    @(negedge clk); in = 2'b01;  // 5Rs ? S2
    rst = 1;                      // reset mid-way
    #20;
    rst = 0;
    in = 2'b00;
    #20;
    $display("Expected: back to S0 after reset");

    $display("\n--- SIMULATION COMPLETE ---");
    #20;
    $finish;
end

endmodule
