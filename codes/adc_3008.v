module adc_3008(clk, rst, cs, mosi, sck, miso, start, seg0, seg1, seg2, seg3, seg4,seg5);
input clk, rst;
input miso;
input start;
output reg cs;
output reg mosi, sck;
output [7:0] seg0, seg1, seg2, seg3, seg4,seg5;

//registor
reg [2:0] state;    //six states
reg [7:0] cnt_clk;  //maximum: 8'd219
reg [4:0] cnt_sck;  //maximum: 5'd19
reg [3:0] cnt_bit;  //4'd10;
reg [2:0] cnt_byte; 
reg rd_sig;         //the signal to adapt data from ADC.
reg [10:0] data_reg;//11 bit data registor
reg [9:0] data_out; //delete the null bit in data_reg.
reg send_data_sig;  //send data to seven-seg display when the read state is finished.
reg [31:0] cnt;     //count the time interval between start_sig.
reg start_sig;      //the signal trigger the state into WAIT_START state.

//seven seg display
wire [3:0] unit;
wire [3:0] ten; 
wire [3:0] hun; 
wire [3:0] thou; 
wire [3:0] ten_thou;
wire [3:0] hun_thou;
wire [19:0] data_bcd;
wire [19:0] data_bcd_vol;

assign data_bcd = {10'b0, data_out};
assign data_bcd_vol = (data_bcd*20'd479)/20'd1023;

parameter [2:0] INTIAL = 3'd0,
                WAIT_START = 3'd1,
                WRITE = 3'd2,
		READ = 3'd3,
		WAIT_END = 3'd4,
		END = 3'd5;
					 
parameter WR_IN = 11'b000001_10010;
parameter cnt_clk_max = 8'd219;
parameter cnt_max = 32'd49_999_999;

//cnt
always@(posedge clk or posedge rst)
if (rst)
cnt <= 32'd0;
else if (cnt == cnt_max)
cnt <= 32'd0;
else if (start == 1'b1)
cnt <= cnt + 1'b1;

//start_sig
always@(posedge clk or posedge rst)
if (rst)
start_sig <= 1'b0;
else if (start == 1'b1 && cnt == cnt_max) //start_sig == 1'b when cnt = cnt_max 
start_sig <= 1'b1;
else 
start_sig <= 1'b0;

//state transition				 
always@(posedge clk or posedge rst)
if (rst)
state <= INTIAL;
else 
case(state)
INTIAL: if (start_sig == 1'b1)
        state <= WAIT_START;
		  else 
		  state <= INTIAL;
		
WAIT_START: if (cnt_byte == 3'd0 && cnt_clk == cnt_clk_max)
            state <= WRITE;
            else 
            state <= WAIT_START;			

WRITE: if (cnt_byte == 3'd1 && cnt_clk == cnt_clk_max)
       state <= READ;
	   else 
	   state <= WRITE;

READ: if (cnt_byte == 3'd2 && cnt_clk == cnt_clk_max)
      state <= WAIT_END;
      else 
      state <= READ;	  
	  
WAIT_END: if (cnt_byte == 3'd3 && cnt_clk == cnt_clk_max)
          state <= END;
		    else 
		    state <= WAIT_END;

END: if (cnt_byte == 3'd4 && cnt_clk == cnt_clk_max)
     state <= INTIAL;
     else 
     state <= END;
default: state <= INTIAL;
endcase

//cnt_clk
//state transfer when cnt_clk == 8'd219
always@(posedge clk or posedge rst)
if (rst)
cnt_clk <= 8'd0;
else if (state == INTIAL)
cnt_clk <= 8'd0;
else if (cnt_clk == cnt_clk_max) 
cnt_clk <= 8'd0;
else if (state != INTIAL)
cnt_clk <= cnt_clk + 1'b1;

//cnt_byte
always@(posedge clk or posedge rst)
if (rst)
cnt_byte <= 3'd0;
else if (cnt_byte == 3'd4 && cnt_clk == cnt_clk_max)
cnt_byte <= 3'd0;
else if (cnt_clk == cnt_clk_max)
cnt_byte <= cnt_byte + 1'b1;

//cnt_sck
//generate the sck
always@(posedge clk or posedge rst)
if (rst)
cnt_sck <= 5'd0;
else if (state == WRITE && cnt_byte == 3'd1 && cnt_sck == 5'd19)
cnt_sck <= 5'd0;
else if (state ==READ && cnt_byte == 3'd2 && cnt_sck == 5'd19)
cnt_sck <= 5'd0;
else if (state == WRITE && cnt_byte == 3'd1)
cnt_sck <= cnt_sck + 1'b1;
else if (state ==READ && cnt_byte == 3'd2)
cnt_sck <= cnt_sck + 1'b1;
else 
cnt_sck <= 1'b0;

//sck
always@(posedge clk or posedge rst)
if (rst)
sck <= 1'b0;
else if (cnt_sck == 5'd0 && cnt_byte == 3'd3)
sck <= 1'b0;
else if (cnt_sck == 5'd0 && cnt_byte == 3'd1 && cnt_bit >= 4'd5)
sck <= 1'b0;
else if (cnt_sck == 5'd10 && cnt_byte == 3'd1 && cnt_bit >= 4'd5)
sck <= 1'b1;
else if (cnt_sck == 5'd0 && cnt_byte == 3'd2)
sck <= 1'b0;
else if (cnt_sck == 5'd10 && cnt_byte == 3'd2)
sck <= 1'b1;
else 
sck <= sck;

//cnt_bit
//conut the number of bits in WRITE and READ state.
always@(posedge clk or posedge rst)
if (rst)
cnt_bit <= 4'd0;
else if (cnt_bit == 4'd10 && cnt_sck == 5'd10)
cnt_bit <= 4'd0;
else if (cnt_sck == 5'd10)
cnt_bit <= cnt_bit + 1'b1;

//cs
always@(posedge clk or posedge rst)
if (rst)
cs <= 1'b1;
else if (start_sig == 1'b1)
cs <= 1'b0;
else if (cnt_byte == 3'd3 && cnt_clk == cnt_clk_max && state == WAIT_END)
cs <= 1'b1;

//mosi
always@(posedge clk or posedge rst)
if (rst)
mosi <= 1'b0;
else if (state == WRITE && cnt_byte == 4'd1 && cnt_sck == 5'd0)
mosi <= WR_IN[10-cnt_bit];
else if (state != WRITE)
mosi <= 1'b0;

//rd_sig
//The rd_sig is used to adapt the data from ADC.
always@(posedge clk or posedge rst)
if (rst)
rd_sig <= 1'b0;
else if (state == READ && cnt_byte == 4'd2 && cnt_sck == 5'd9)
rd_sig <= 1'b1;
else 
rd_sig <= 1'b0;

//data_reg
always@(posedge clk or posedge rst)
if (rst)
data_reg <= 11'd0;
else if (rd_sig == 1'b1)
data_reg <= {data_reg[9:0], miso};

//send_data_sig
//Send data to seven-seg display when finished the READ state.
always@(posedge clk or posedge rst)
if (rst)
send_data_sig <= 1'b0;
else if (cnt_byte == 4'd2 && cnt_clk == cnt_clk_max)
send_data_sig <= 1'b1;
else 
send_data_sig <= 1'b0;

//data_out
//delete the null bit in data_reg.
always@(posedge clk or posedge rst)
if (rst)
data_out <= 10'd0;
else if (send_data_sig == 1'b1)
data_out <= data_reg[9:0];
else 
data_out <= data_out;


//wire connection
bcd_8421 bcd_8421_inst(
.clk(clk), 
.rst(rst), 
.data(data_bcd_vol), 
.unit(unit), 
.ten(ten), 
.hun(hun), 
.thou(thou), 
.ten_thou(ten_thou), 
.hun_thou(hun_thou)
);

//seven seg
seven_seg s0(
.en(1'b1),
.in(unit), 
.seg(seg0));
				 			 
seven_seg s1(
.en(1'b1),
.in(ten), 
.seg(seg1));

seven_seg_dot s2(
.en(1'b1),
.in(hun), 
.seg(seg2));

seven_seg s3(
.en(1'b1),
.in(thou), 
.seg(seg3));

seven_seg s4(
.en(1'b1),
.in(ten_thou), 
.seg(seg4));

seven_seg s5(
.en(1'b1),
.in(hun_thou), 
.seg(seg5));

endmodule
