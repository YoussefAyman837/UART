module UART_top(

    input  wire        clk,
    input  wire        rst_n,
    
    // UART Interface
    

    // Transmit Interface
       // Data to transmit
    input wire [15:0] baud_divisor ,
    output o_framing_error,
    output o_overrun_error , 
    input wire [1:0] i_parity_type , 
    output o_parity_error ,
    output wire o_tx , 
    input wire i_rx ,
    output wire i_full , i_almostfull , i_overflow , i_almostempty , i_underflow , i_wr_ack, 
    output wire o_almostfull , o_overflow , o_empty , o_almostempty , o_underflow , o_wr_ack, 
    input wire [7:0]i_data_in , 
    input wire i_wr_en , o_fifo_rd_en, 
    output [7:0] o_fifo_data_out
);



wire [7:0]  tx_data , rx_data; 

wire  i_empty ,   i_fifo_rd_en , o_fifo_wr_en ,o_full ;


FIFO f1(.clk(clk) , .rst_n(rst_n) , .rd_en(i_fifo_rd_en) , .wr_en(i_wr_en) , .data_in(i_data_in) , .full(i_full) , .almostfull(i_almostfull) , .overflow(i_overflow) , .empty(i_empty) , .almostempty(i_almostempty) , .underflow(i_underflow) , .wr_ack(i_wr_ack) , .data_out(tx_data));



uart_tx t1(.clk(clk) , .rst_n(rst_n) , .tx(o_tx) , .tx_data(tx_data) , .i_fifo_empty(i_empty) , .o_fifo_rd_en(i_fifo_rd_en) , .baud_tick_o(baud_tick_o) , .baud_divisor(baud_divisor) , .i_parity_type(i_parity_type));

uart_rx r1(.clk(clk) , .rst_n(rst_n) , .rx(i_rx) , .rx_data(rx_data) ,.baud_divisor(baud_divisor) , .o_overrun_error(o_overrun_error) , .o_framing_error(o_framing_error) , .o_parity_error(o_parity_error) , .i_parity_type(i_parity_type) , .o_fifo_wr_en(o_fifo_wr_en) , .full(o_full));

FIFO f2(.clk(clk) , .rst_n(rst_n) , .rd_en(o_fifo_rd_en) , .data_in(rx_data) , .full(o_full) , .almostfull(o_almostfull) , .overflow(o_overflow) , .empty(o_empty) , .almostempty(o_almostempty) , .underflow(o_underflow) , .wr_ack(o_wr_ack) ,.data_out(o_fifo_data_out) , .wr_en(o_fifo_wr_en));



endmodule
