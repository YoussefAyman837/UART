import UART_sb_pkg::*;
import UART_trx_pkg::*;
import UART_BFM_pkg::*;
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

    UART_transaction trans = new();
    UART_sb sb =new();
    UART_if u_if();
    UART_bfm bfm=new(u_if);
    UART_top top(.* , .i_rx(u_if.rx) , .o_tx(u_if.tx));

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end


assign u_if.clk = clk;
assign u_if.rst_n = rst_n;


    // Test for a Framing Error
initial begin

  full_system_test();

//loopback_test();
//framing_error_test();
//overrun_test();
end

task full_system_test();
  
  rst_n = 0;
  top.t1.o_fifo_rd_en=0;
  o_fifo_rd_en=0;
  baud_divisor = 16'd434;
  @(negedge clk);
  @(negedge clk);
  bfm.set_baud_rate(50000000,115200);
  rst_n = 1;

  fork
    begin
      sb.run();
    end

    begin
    forever begin
      @(negedge u_if.clk);
      if(!o_empty)begin
        o_fifo_rd_en=1'b1;
        @(negedge u_if.clk);
        sb.rx_mailbox.put(o_fifo_data_out);
        o_fifo_rd_en=1'b0;
      end
    end  
    end
  join_none

  bfm.run_serial_burst_test(10 , sb);
  #20000;
endtask //

/*
task overrun_test();
  rst_n = 0;
  top.t1.o_fifo_rd_en=0;
  o_fifo_rd_en=0;
  i_parity_type = 2'b00;
  baud_divisor = 16'd434;
  @(negedge clk);
  @(negedge clk);
  bfm.set_baud_rate(50000000,115200);
  rst_n = 1;

  bfm.send_burst(8);
  repeat(10) #(8680);

  bfm.send_burst(1);
  wait(o_overrun_error);
  $display("SUCCESS: o_overrun_error flag was asserted!");
endtask //


task framing_error_test();
    $display("--- Starting Framing Error Test ---");
  rst_n = 0;
  top.t1.o_fifo_rd_en=0;
  o_fifo_rd_en=0;
  i_parity_type = 2'b01;
  baud_divisor = 16'd434;
  @(negedge clk);
  @(negedge clk);
  rst_n = 1;

  bfm.set_baud_rate(50000000,115200);
  bfm.send_corrupted_byte(8'hAA);
  @(negedge clk);
  wait(o_framing_error);
  $display("SUCCESS: o_framing_error flag was asserted!");

endtask //




task loopback_test();
    
  rst_n=0;
  baud_divisor=16'd434;
  top.t1.o_fifo_rd_en=0;
  o_fifo_rd_en=0;

  @(negedge clk);
  @(negedge clk);
  rst_n=1;

  fork
    sb.run();
  join_none

 for (i = 0;i<7 ;i++ ) begin
    wait(!i_full);
    assert(trans.randomize());
    i_data_in=trans.data;
    i_parity_type=trans.parity_type;
    i_wr_en=1;
    @(negedge clk);
    i_wr_en=0;
    sb.tx_mailbox.put(trans.data);
 end   

wait(i_almostempty);

while(!o_empty)begin
    @(negedge clk);
    o_fifo_rd_en=1;
    @(negedge clk);
    o_fifo_rd_en=0;
    sb.rx_mailbox.put(o_fifo_data_out);
end

endtask //
  */
assert property(@(posedge clk)(top.t1.cs==3'b001 |=> !top.rx));
assert property(@(posedge clk)((top.t1.baud_counter==baud_divisor-1) |-> top.t1.baud_tick_o));
assert property(@(posedge clk)(top.t1.cs==3'b011 |=> top.rx==top.t1.parity ));
assert property(@(posedge clk)(top.t1.cs==3'b100 |=> top.rx));
assert property(@(posedge clk)(top.r1.cs==3'b011) |=> top.rx == top.r1.recieved_parity);
assert property(@(posedge clk)(top.r1.cs==3'b011) |=> top.t1.parity == top.r1.recieved_parity);
assert property(@(posedge clk)(top.r1.cs==3'b100 && top.r1.rx==1'b0 && top.r1.baud_tick) |=> o_framing_error);
assert property(@(posedge clk)(top.r1.cs==3'b100 && top.r1.recieved_parity != top.r1.parity) |=> o_parity_error);


endmodule

