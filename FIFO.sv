////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO( clk , rst_n , wr_en , rd_en , data_in , 
 wr_ack , overflow , full , empty , almostfull , almostempty , underflow , data_out
);
parameter FIFO_WIDTH = 8;
parameter FIFO_DEPTH = 8;
input logic [FIFO_WIDTH-1:0] data_in ;
output logic [FIFO_WIDTH-1:0] data_out;
output logic wr_ack , overflow , full , empty , almostfull , almostempty , underflow ; 
input logic clk , rst_n , wr_en , rd_en ; 


 
localparam max_fifo_addr = $clog2(FIFO_DEPTH);

logic [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
logic [max_fifo_addr:0] count;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_ptr <= 0;
		wr_ack <=0; 
		overflow<=0;                                
	end
	else if (wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;                               //overflow handling
	end
	else if(wr_en && full) begin 
		overflow<=1;
	end
	else begin
		overflow<=0;
		wr_ack<=0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= 0;
		underflow<=0;
	end
	else if (rd_en && count != 0) begin
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
	else if(rd_en && empty)begin
		underflow<=1;
	end                                                       //underflow handling
	else begin
		underflow<=0; 
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if ( ({wr_en, rd_en} == 2'b01) && !empty)
			count <= count - 1;
	end
end

assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
assign almostfull = (count == FIFO_DEPTH-1)? 1 : 0;   //FIFO_DEPTH -2 is wrong
assign almostempty = (count == 1)? 1 : 0;


assert property(@(posedge clk)(wr_en && full |=> overflow));

assert property(@(posedge clk)(rd_en &&empty |=>underflow));     

assert property (@(posedge clk) disable iff(!rst_n) (wr_en && almostfull && !rd_en) |=> full); 
assert property (@(posedge clk) disable iff(!rst_n) (almostempty && rd_en && !wr_en) |=> empty);
assert property(@(posedge clk)((wr_en && !full) |=> wr_ack));

assert property(@(posedge clk)(count==FIFO_DEPTH) |-> full);

assert property(@(posedge clk)(count==FIFO_DEPTH-1) |-> almostfull);

assert property(@(posedge clk)(count==0) |-> empty);

assert property(@(posedge clk)(count==1) |-> almostempty);

endmodule