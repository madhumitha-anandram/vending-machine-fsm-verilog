module vending_machine_with_timeout(
    input clk, rst,
    input [1:0] in,
    output reg [1:0] change,
    output reg out
);

parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;
parameter rs5 = 2'b01, rs10 = 2'b10;

reg [1:0] ps, ns;
reg [3:0] counter;
reg [1:0] in_reg;              

wire timeout = (counter == 4'd10);


always @(posedge clk) begin
    if (rst) in_reg <= 2'b00;
    else     in_reg <= in;     // sample in at posedge, use next cycle
end

always @(posedge clk) begin
    if (rst || ps == s0)
        counter <= 4'd0;
    else if (in_reg == rs5 || in_reg == rs10)
        counter <= 4'd0;
    else
        counter <= counter + 1;
end

always @(posedge clk) begin
    if (rst) ps <= s0;
    else     ps <= ns;
end

always @(*) begin
    ns     = s0;
    out    = 1'b0;
    change = 2'b00;

    case (ps)
        s0: begin
            if      (in_reg == rs5)  ns = s1;
            else if (in_reg == rs10) ns = s2;
            else                     ns = s0;
        end

        s1: begin
            if (timeout) begin
                ns     = s0;
                change = rs5;
            end
            else if (in_reg == rs5)  ns = s2;
            else if (in_reg == rs10) begin
                ns  = s0;
                out = 1'b1;
            end
            else ns = s1;
        end

        s2: begin
            if (timeout) begin
                ns     = s0;
                change = rs10;
            end
            else if (in_reg == rs5) begin
                ns  = s0;
                out = 1'b1;
            end
            else if (in_reg == rs10) begin
                ns     = s0;
                change = rs5;
                out    = 1'b1;
            end
            else ns = s2;
        end

        default: ns = s0;
    endcase
end

endmodule
