//display the decimal point of seven-segment display
module seven_seg_dot (en,in,seg);
input [3:0] in;
input en;
output [7:0] seg;

reg [7:0] seg;
always@(en or in)

begin
 if (!en) seg=8'b11111111;
 else case(in)
 4'd0: seg=8'b01000000;
 4'd1: seg=8'b01111001;
 4'd2: seg=8'b00100100;
 4'd3: seg=8'b00110000;
 4'd4: seg=8'b00011001;
 4'd5: seg=8'b00010010;
 4'd6: seg=8'b00000010;
 4'd7: seg=8'b01011000;
 4'd8: seg=8'b00000000;
 4'd9: seg=8'b00010000;
 endcase
 end
 endmodule 