module UART_top(

    input  wire        clk,
    input  wire        rst_n,
    
    // UART Interface
    

    // Transmit Interface
    input  wire [7:0]  tx_data,    // Data to transmit
    input  wire        tx_valid,   // Assert to send data
    output         tx_ready ,     // Active-low reset        
    output   [7:0]  rx_data,     // Received parallel data
    output          rx_valid,    // Data valid pulse
    input  wire        rx_ready ,
    output baud_tick_o
);


wire rx;

uart_tx t1(.clk(clk) , .rst_n(rst_n) , .tx(rx) , .tx_data(tx_data) , .tx_valid(tx_valid) , .tx_ready(tx_ready) , .baud_tick_o(baud_tick_o));

uart_rx r1(.clk(clk) , .rst_n(rst_n) , .rx(rx) , .rx_data(rx_data) , .rx_valid(rx_valid), .rx_ready(rx_ready));




endmodule