`timescale 1ns/1ps
module vending_machine_tb();

reg clk, rst;
reg [1:0] in;
wire [1:0] change;
wire out;

vending_machine_with_timeout dut(
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

always @(posedge clk) begin
    $display("T=%0t | in=%0d Rs | out=%b | change=%0d Rs | state=%0d | counter=%0d",
              $time, in*5, out, change*5, dut.ps, dut.counter);
end

task do_reset;
    begin
        rst = 1;
        in  = 2'b00;
        #20;
        rst = 0;
        #10;
    end
endtask

// KEY FIX: clear in after just 1ns, not after a full cycle
task insert_coin;
    input [1:0] coin;
    begin
        @(negedge clk);   // wait for negedge (midpoint)
        in = coin;         // set ? sampled at next posedge only
        #1;                // hold for just 1ns
        in = 2'b00;        // clear ? gone before posedge after that
    end
endtask

task wait_cycles;
    input integer n;
    begin
        in = 2'b00;
        repeat(n) @(negedge clk);
    end
endtask

initial begin

    do_reset;

    $display("\n=== TEST 1: 5Rs + 5Rs then TIMEOUT ? change=10Rs ===");
    insert_coin(2'b01);
    insert_coin(2'b01);
    wait_cycles(12);
    $display("Expected: out=0, change=10Rs");
    do_reset;

    $display("\n=== TEST 2: 5Rs + 10Rs ? out=1, change=0Rs ===");
    insert_coin(2'b01);
    insert_coin(2'b10);
    #20;
    $display("Expected: out=1, change=0Rs");
    do_reset;

    $display("\n=== TEST 3: 10Rs + 5Rs ? out=1, change=0Rs ===");
    insert_coin(2'b10);   // S0?S2 only, no output
    insert_coin(2'b01);   // S2+5Rs ? out=1
    #20;
    $display("Expected: out=1, change=0Rs");
    do_reset;

    $display("\n=== TEST 4: 10Rs + 10Rs ? out=1, change=5Rs ===");
    insert_coin(2'b10);
    insert_coin(2'b10);
    #20;
    $display("Expected: out=1, change=5Rs");
    do_reset;

    $display("\n=== TEST 5: 10Rs then TIMEOUT ? change=10Rs ===");
    insert_coin(2'b10);
    wait_cycles(12);
    $display("Expected: out=0, change=10Rs");
    do_reset;

    $display("\n=== TEST 6: 5Rs then TIMEOUT ? change=5Rs ===");
    insert_coin(2'b01);
    wait_cycles(12);
    $display("Expected: out=0, change=5Rs");
    do_reset;

    $display("\n=== TEST 7: 5Rs + 5Rs + 5Rs ? out=1, change=0Rs ===");
    insert_coin(2'b01);
    insert_coin(2'b01);
    insert_coin(2'b01);
    #20;
    $display("Expected: out=1, change=0Rs");
    do_reset;

    $display("\n=== TEST 8: 5Rs + wait 8 + 5Rs ? S2 timeout ===");
    insert_coin(2'b01);
    wait_cycles(8);
    insert_coin(2'b01);
    wait_cycles(12);
    $display("Expected: out=0, change=10Rs");
    do_reset;

    $display("\n=== TEST 9: reset mid-transaction ? S0 ===");
    insert_coin(2'b01);
    insert_coin(2'b01);
    rst = 1; #20; rst = 0;
    in = 2'b00; #20;
    $display("Expected: state=S0, out=0, change=0Rs, counter=0");
    do_reset;

    $display("\n=== TEST 10: no coin ? stay S0 ===");
    wait_cycles(15);
    $display("Expected: state=S0, out=0, change=0Rs, counter=0");

    $display("\n=== SIMULATION COMPLETE ===");
    #20;
    $finish;
end

endmodule
