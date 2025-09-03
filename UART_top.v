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
    output baud_tick_o ,
    input wire [15:0] baud_divisor ,
    output o_framing_error,
    output o_overrun_error , 
    input wire [1:0] i_parity_type , 
    output o_parity_error ,
    output wire o_tx , 
    input wire i_rx
    
);


wire rx;

uart_tx t1(.clk(clk) , .rst_n(rst_n) , .tx(o_tx) , .tx_data(tx_data) , .tx_valid(tx_valid) , .tx_ready(tx_ready) , .baud_tick_o(baud_tick_o) , .baud_divisor(baud_divisor) , .i_parity_type(i_parity_type));

uart_rx r1(.clk(clk) , .rst_n(rst_n) , .rx(i_rx) , .rx_data(rx_data) , .rx_valid(rx_valid), .rx_ready(rx_ready), .baud_divisor(baud_divisor) , .o_overrun_error(o_overrun_error) , .o_framing_error(o_framing_error) , .o_parity_error(o_parity_error) , .i_parity_type(i_parity_type));




endmodule
