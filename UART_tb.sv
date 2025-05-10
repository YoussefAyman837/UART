module UART_tb;

    logic clk;
    logic rst_n;

    // UART Interface

    // Transmit Interface
    logic [7:0] tx_data;
    logic tx_valid;
    logic tx_ready;
    logic baud_tick_o;
    // Receive Interface
    logic [7:0] rx_data;
    logic rx_valid;
    logic rx_ready;
    integer i;
    // Instantiate UART Transmitter and Receiver
    UART_top top(.*);

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end


initial begin
    rst_n = 0;
    tx_valid = 0;
    @(negedge clk);
    rst_n = 1;

    for (i = 0; i < 4; i = i + 1) begin
        rx_ready=0;
        wait(baud_tick_o);
        tx_valid=1;
        rx_ready=1;
        tx_data=$random;
        wait(rx_valid);
        
    end
end



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
