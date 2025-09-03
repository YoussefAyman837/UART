module uart_tx (
    input  wire        clk,
    input  wire        rst_n,
    output baud_tick_o,
    // UART Interface
    output reg        tx,         // UART Transmit line

    // Transmit Interface
    input wire [15:0] baud_divisor,
    input  wire [7:0]  tx_data,    // Data to transmit
    input  wire        tx_valid,   // Assert to send data
    output reg        tx_ready,   // Transmit ready for new data
    input wire [1:0] i_parity_type
);
parameter IDLE =3'b000;
parameter START_BIT=3'b001;
parameter DATA_BITS=3'b010;
parameter PARITY_BIT=3'b011;
parameter STOP_BIT=3'b100;
parameter CLK_FREQ = 50000000;

reg[7:0] tx_shift_reg;
reg[2:0] ns,cs;
reg[9:0] baud_counter;
wire baud_tick;
reg [3:0] baud_tick_counter;
wire parity;

assign parity = (i_parity_type == 2'b01)? ^tx_data : 
                (i_parity_type == 2'b11)? ~^tx_data :
                1'b1;

assign baud_tick=(baud_counter== baud_divisor - 1); // 50 MHZ clock
assign baud_tick_o=baud_tick;

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
            if(tx_valid && baud_tick  )begin
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
        tx<=1'b1;
        tx_ready<=1'b1;
        baud_tick_counter<=0;
        tx_shift_reg<=8'b00000000;
    end
    else begin
        case (cs)
            IDLE:begin
                tx_ready<=1; 
                baud_tick_counter<=0;
                
            end
            START_BIT:begin
                tx_ready<=0;
                tx<=0;
                if(tx_valid )begin
                    tx_shift_reg<=tx_data;
                end
            end
            DATA_BITS:begin
                if(baud_tick)begin
              tx<=tx_shift_reg[0];
              tx_shift_reg<= tx_shift_reg >> 1;
              baud_tick_counter<=baud_tick_counter+1;
            end
            end
            PARITY_BIT:begin
                    tx<=parity;
            end
            STOP_BIT:begin
                tx<=1;
            end
        endcase
    end
end






endmodule
