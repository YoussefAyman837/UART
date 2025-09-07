module UART_tb;

    logic clk;
    logic rst_n;

    // UART Interface

    // Transmit Interface
    logic baud_tick_o;
    // Receive Interface
    logic [7:0] i_data_in;
    logic [15:0] baud_divisor;
    integer i;
    logic o_overrun_error;
    logic o_framing_error;
    logic o_parity_error;
    logic [1:0] i_parity_type;
    logic uart_line;
    logic i_full ;
    logic i_almostfull ;
    logic i_overflow ;
    logic i_almostempty ;
    logic i_underflow ;
    logic i_wr_ack; 
    logic i_wr_en;
    logic o_almostfull , o_overflow , o_empty , o_almostempty , o_underflow , o_wr_ack , o_fifo_rd_en;
    logic [7:0] o_fifo_data_out;
    UART_top top(.o_tx(uart_line) ,.i_rx(uart_line), .*);

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end





    // Test for a Framing Error
initial begin
  rst_n=0;
  baud_divisor=16'd434;
  i_parity_type=2'b01;
  top.t1.o_fifo_rd_en=0;
  o_fifo_rd_en=0;

  @(negedge clk);
  @(negedge clk);
  rst_n=1;
 for (i = 0;i<14 ;i++ ) begin
    i_data_in=$random;
    i_wr_en=1;
    @(negedge clk);
    i_wr_en=0;
 end   

wait(o_almostempty);
o_fifo_rd_en=1;


  /*  rst_n = 0;
    baud_divisor =16'd434; 
    i_parity_type = 2'b01;
    tx_valid = 0;
    @(negedge clk);
    rst_n = 1;




        rx_ready=0;
        wait(baud_tick_o);
        tx_valid=1;
        rx_ready=1;
        tx_data=8'h01;
        //repeat(434 * 10 ) @(posedge clk);

        //force uart_line = 1'b0 ;
        wait(rx_valid);
        //release uart_line ;
*/
end
    
    /*
    for (i = 0; i < 4; i = i + 1) begin
        rx_ready=0;
        wait(baud_tick_o);
        tx_valid=1;
        rx_ready=1;
        tx_data=$random;
        wait(rx_valid);
    end
    
end


*/
  /*  initial begin
        rst_n=0;
        @(negedge clk);
        rst_n=1;
        for (i =0 ;i<4 ;i=i+1 ) begin
            
            tx_data=$random;
            tx_valid=1;
            rx_ready=1;
            repeat(563) @(negedge clk);
        end
    end
*/

  /*  // Stimulus
    initial begin
        // Initialize
        rst_n = 0;
       @(negedge clk);
       rst_n=1;
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       rx_ready=1;
       tx_valid=1;
       @(negedge clk);
       tx_data=8'b00001111;
 #500;
 rx_ready=1;
        
    end
*/
endmodule
