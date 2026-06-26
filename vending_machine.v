module vending_machine(
input clk,rst,
input [1:0] in,
output reg [1:0] change,
output reg out
);

parameter s0 = 2'b00, s1 = 2'b01, s2 = 2'b10;

parameter rs5 = 2'b01, rs10 = 2'b10, rs0 = 2'b00;

reg [1:0] ps, ns;

always@(posedge clk) begin

if(rst==1) begin
 ps <=s0;
end
else begin
ps <=ns;
end
end

always@(ps or in) begin
case (ps)

s0: begin
if(in==rs5)begin
ns = s1;
out = 1'b0;
change = rs0;
end
else if(in==rs0) begin
ns = s0;
out = 1'b0;
change = rs0;
end

else if(in==rs10) begin
ns = s2;
out = 1'b0;
change = rs0;
end
end

s1: begin
if(in==rs0) begin
ns = s0;
change = rs5;
out = 1'b0;
end
else if (in==rs5) begin
ns = s2;
change = rs0;
out = 1'b0;
end
else if(in==rs10) begin
ns = s0;
change = rs0;
out = 1'b1;
end
end

s2: begin
if(in==rs0) begin
ns = s0;
change = rs10;
out = 1'b0;
end
else if (in==rs5) begin
ns = s0;
change = rs0;
out = 1'b1;
end
else if(in==rs10) begin
ns = s0;
change = rs5;
out = 1'b1;
end
end

default: begin
ns     = s0;
out    = 1'b0;
change = rs0;
end
endcase
end

endmodule


 

