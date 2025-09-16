package UART_pkg;

class UART_transaction;
logic [15:0] baud_divisor ;
logic o_framing_error;
logic o_overrun_error ; 
logic [1:0] i_parity_type ; 
logic o_parity_error ;
logic o_tx ;
logic i_rx ;
logic i_full , i_almostfull , i_overflow , i_almostempty , i_underflow , i_wr_ack; 
logic o_almostfull , o_overflow , o_empty , o_almostempty , o_underflow , o_wr_ack; 
logic rand [7:0]i_data_in ; 
logic rand i_wr_en ;
logic o_fifo_rd_en; 
logic [7:0] o_fifo_data_out;

constraint c1{if(!i_full)begin
  i_wr_en = 1;
end
else begin
  i_wr_en=0;
end;};

  function new();
    
  endfunction //new()
endclass //UART_transaction

  
endpackage