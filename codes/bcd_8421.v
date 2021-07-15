//Binary-Coded-Decimal
module bcd_8421 (clk, rst, data, unit, ten, hun, thou, ten_thou, hun_thou);
input clk, rst;
input [19:0] data;
output [3:0] unit, ten, hun, thou, ten_thou, hun_thou;

reg [5:0]  cnt_shift;
reg [43:0] data_shift; //6個七段顯示器總共24位元，再加上20位元的data
reg        shift_sig;
reg [3:0]  unit, ten, hun, thou, ten_thou, hun_thou;


//shift registor
//cnt_shift 
always@(posedge clk or posedge rst)
if (rst)
cnt_shift <= 5'd0;
else if (cnt_shift == 5'd21 && shift_sig == 1'b0)
cnt_shift <= 5'd0;
else if (shift_sig == 1'b0)
cnt_shift <= cnt_shift +1'b1;
else 
cnt_shift <= cnt_shift;

//data_shift 
always@(posedge clk or posedge rst)
if (rst)
data_shift <= 44'b0;

else if (cnt_shift == 5'd0 && shift_sig == 1'b0)
data_shift <= {24'd0, data};

else if ((cnt_shift <= 5'd20) && (shift_sig == 1'b1))
begin
data_shift[23:20] <= (data_shift[23:20] > 4'b0100)?(data_shift[23:20] + 4'b0011):(data_shift[23:20]);

data_shift[27:24] <= (data_shift[27:24] > 4'b0100)?(data_shift[27:24] + 4'b0011):(data_shift[27:24]);

data_shift[31:28] <= (data_shift[31:28] > 4'b0100)?(data_shift[31:28] + 4'b0011):(data_shift[31:28]);

data_shift[35:32] <= (data_shift[35:32] > 4'b0100)?(data_shift[35:32] + 4'b0011):(data_shift[35:32]);

data_shift[39:36] <= (data_shift[39:36] > 4'b0100)?(data_shift[39:36] + 4'b0011):(data_shift[39:36]);

data_shift[43:40] <= (data_shift[43:40] > 4'b0100)?(data_shift[43:40] + 4'b0011):(data_shift[43:40]);
end

else if ((cnt_shift <= 5'd20) && (shift_sig == 1'b0))
data_shift <= data_shift << 1;
else 
data_shift <= data_shift;

//shift_sig 
always@(posedge clk or posedge rst)
if(rst == 1'b1)
shift_sig <= 1'b1;
else 
shift_sig <= ~shift_sig;

//display assignment
always@(posedge clk or posedge rst)
if(rst)
begin
unit <= 4'd0;
ten  <= 4'd0;
hun  <= 4'd0;
thou <= 4'd0;
ten_thou <= 4'd0;
hun_thou <= 4'd0;
end
else if (cnt_shift == 5'd21)
begin
 unit  <= data_shift[23:20];
 ten   <= data_shift[27:24];
 hun   <= data_shift[31:28];
 thou  <= data_shift[35:32];
 ten_thou <= data_shift[39:36];
 hun_thou <= data_shift[43:40];
 end
 
 endmodule