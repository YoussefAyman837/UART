module uart_rx (
    input  wire        clk,         // System clock
    input  wire        rst_n,       // Active-low reset
    input  wire        rx,          // UART serial receive input
    output reg  [7:0]  rx_data,     // Received parallel data
    input wire [15:0] baud_divisor ,
    output reg        o_framing_error,
    output reg        o_overrun_error,
    input wire [1:0] i_parity_type , 
    output reg o_parity_error , 
    output reg o_fifo_wr_en , 
    input wire full
);

// Internal signals
reg  [2:0] cs, ns;                  // State machine current/next state
reg  [7:0] rx_shift_reg;             // Shift register for received data            
reg        rx_sampled_bit;           // Sampled bit

parameter IDLE =3'b000;
parameter START_BIT=3'b001;
parameter DATA_BITS=3'b010;
parameter PARITY_BIT=3'b011;
parameter STOP_BIT=3'b100;
parameter CLK_FREQ= 50000000;

reg mid_bit_sample;
reg recieved_parity;
reg[9:0] baud_counter;
wire baud_tick;
reg [3:0] baud_tick_counter;
wire parity;

reg data_written;


assign baud_tick=(baud_counter== baud_divisor - 1); 
assign parity = (i_parity_type == 2'b01)? ^rx_shift_reg:
                (i_parity_type == 2'b10)? ~^rx_shift_reg:
                1'b1;




always @(posedge clk or negedge rst_n) begin // Handling Baud Counter
    if(!rst_n)
        baud_counter<=0;
    else if(baud_tick )
        baud_counter<=0;
    else
        baud_counter<=baud_counter+1;
end


always @(posedge clk or negedge rst_n) begin
    if(baud_counter == (baud_divisor >>1) -1)begin
        mid_bit_sample<=1;
    end
    else begin
        mid_bit_sample <=0;
    end
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
            if(!full)begin
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
                if(i_parity_type == 2'b00)begin
                    ns=STOP_BIT;

                end
                else begin
                    ns=PARITY_BIT;
                end

            end
            else begin
                ns=DATA_BITS;
            end
        end
        PARITY_BIT:begin
            if(baud_tick)begin
                ns=STOP_BIT;
            end
            else begin
                ns=PARITY_BIT;
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
        baud_tick_counter <= 0;
        rx_shift_reg <= 0;
        o_framing_error <= 0;
        o_overrun_error <= 0;
        o_parity_error <= 0;
        o_fifo_wr_en <=0;
    end
    else begin
        case (cs)
            IDLE:begin
                baud_tick_counter<=0;
                data_written<=0;

                if(rx==0)begin
                    rx_shift_reg<=0;
                end
            end
            START_BIT:begin
                if(mid_bit_sample)begin
                   if(rx==1'b0)begin
                    baud_tick_counter<=0;
                   end
                end
                
            end
            DATA_BITS:begin
                if(mid_bit_sample)begin
              rx_shift_reg<={rx,rx_shift_reg[7:1]};
                end
                if(baud_tick)begin
                    baud_tick_counter<=baud_tick_counter+1;
                end
            end
            PARITY_BIT:begin
                    recieved_parity <= rx ;
            end
            STOP_BIT:begin
                if(!data_written)begin
                    o_fifo_wr_en<=1;
                    o_overrun_error <= full;
                end
                else begin
                    o_fifo_wr_en<=0;
                end
               
                if(!full)begin
                        rx_data<=rx_shift_reg;
                        data_written<=1;
                    end
                if(baud_tick)begin

                    // Check for a framing error. Stop bit must be '1'.
                    if (rx == 1'b0) begin
                        o_framing_error <= 1'b1;
                    end
                    if(i_parity_type != 2'b00 && recieved_parity!= parity)begin
                        o_parity_error <= 1'b1 ;
                    end
                
                end
            end
        endcase
    end
end
endmodule
