module uart_rx (
    input  wire        clk,         // System clock
    input  wire        rst_n,       // Active-low reset
    input  wire        rx,          // UART serial receive input
    output reg  [7:0]  rx_data,     // Received parallel data
    output reg         rx_valid,    // Data valid pulse
    input  wire        rx_ready     // Receiver ready for new data
);

// Internal signals
reg  [1:0] cs, ns;                  // State machine current/next state
reg  [7:0] rx_shift_reg;             // Shift register for received data            
reg        rx_sampled_bit;           // Sampled bit

parameter IDLE =2'b00;
parameter START_BIT=2'b01;
parameter DATA_BITS=2'b10;
parameter STOP_BIT=2'b11;

reg[9:0] baud_counter;
wire baud_tick;
reg [3:0] baud_tick_counter;

assign baud_tick=(baud_counter==50); // 50 MHZ clock with baud rate 115200

always @(posedge clk or negedge rst_n) begin // Handling Baud Counter
    if(!rst_n)
        baud_counter<=0;
    else if(baud_tick)
        baud_counter<=0;
    else
        baud_counter<=baud_counter+1;
end

always @(posedge clk or negedge rst_n) begin   // state transition
    if(!rst_n)begin
        cs<=IDLE;
    end
    else begin
        cs<=ns;
    end
end

always @(*) begin   //next state handling
    case (cs)
        IDLE:begin
            if(rx_ready  && baud_tick)begin
                ns=START_BIT;
            end
            else 
            ns=IDLE;
        end 
        START_BIT:begin
            if(baud_tick)begin
                ns=DATA_BITS;
            end
            else
            ns=START_BIT;
        end
        DATA_BITS:begin
            if(baud_tick && baud_tick_counter==4'b1000)begin
                ns=STOP_BIT;
            end
            else begin
                ns=DATA_BITS;
            end
        end
        STOP_BIT: begin
            if(baud_tick)begin
                ns=IDLE;
            end
            else
            ns=STOP_BIT;
        end
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_data<=0;
        rx_valid<=0;
        baud_tick_counter <= 0;
        rx_shift_reg <= 0;
    end
    else begin
        case (cs)
            IDLE:begin
                rx_valid<=0; 
                baud_tick_counter<=0;
                if(rx==0)begin
                    rx_shift_reg<=0;
                end
            end
            START_BIT:begin
                if(baud_tick)begin
                   if(rx==1'b0)begin
                    baud_tick_counter<=0;
                   end
                end
                
            end
            DATA_BITS:begin
                if(baud_tick)begin
              rx_shift_reg<={rx,rx_shift_reg[7:1]};
              baud_tick_counter<=baud_tick_counter+1;
            end
            end
            STOP_BIT:begin
                if(baud_tick)begin
                rx_valid<=1;
                rx_data<=rx_shift_reg;
                end
            end
        endcase
    end
end
endmodule