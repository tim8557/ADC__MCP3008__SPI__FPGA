//hex_seven_segment
module seven_seg(en,in,seg);
input [3:0] in;
input en;
output [7:0] seg;

reg [7:0] seg;
always@(en or in)

begin
 if (!en) seg=8'b11111111;
 else case(in)
 4'd0: seg=8'b11000000;
 4'd1: seg=8'b11111001;
 4'd2: seg=8'b10100100;
 4'd3: seg=8'b10110000;
 4'd4: seg=8'b10011001;
 4'd5: seg=8'b10010010;
 4'd6: seg=8'b10000010;
 4'd7: seg=8'b11011000;
 4'd8: seg=8'b10000000;
 4'd9: seg=8'b10010000;
 endcase
 end
 endmodule 