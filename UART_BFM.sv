package UART_BFM_pkg;
import UART_trx_pkg::*;
import UART_sb_pkg::*;

class UART_bfm;
virtual UART_if vif;
UART_transaction trans;
int baud_period;
UART_sb scb;

covergroup cg_inst with function sample(UART_transaction trans);

 cp_parity_type : coverpoint trans.parity_type {
    bins no_parity = {2'b00};
    bins odd_parity = {2'b01};
    bins even_parity = {2'b10};
    bins illegal_parity = {2'b11};
  }
  // Coverpoint for Data Corner Cases
  cp_data : coverpoint trans.data {
    bins zeros = {8'h00};
    bins ones = {8'hFF};
    bins walking_ones = {8'b00000001, 8'b00000010, 8'b00000100, 8'b00001000, 8'b00010000, 8'b00100000, 8'b01000000, 8'b10000000};
    bins others = default;
  }

  cross_parity_data : cross cp_parity_type, cp_data;

endgroup

//uart_cg cg_inst;
  function new(virtual UART_if vif);
    this.vif=vif;
    this.trans=new();
    this.cg_inst=new();
  endfunction //new()


  /*task send_burst(input int num_burst , output UART_transaction t);

    for (int i =0 ;i<num_burst ;i++ ) begin
      t.data=$random;
      t.parity_type=$random;
      send_byte(t);
    end
  endtask //
*/
  task  set_baud_rate(input int freq , input int baud_rate);
    baud_period = freq/baud_rate;
    $display("baud_period %d" , baud_period);
  endtask //

  task  send_byte(input UART_transaction t);

     bit parity_bit;
        // Calculate parity based on the transaction
        case (t.parity_type)
            2'b01: parity_bit = ^t.data;    // Odd Parity
            2'b10: parity_bit = ~^t.data;   // Even Parity
            default: parity_bit = 1'b1; // Default for no parity
        endcase
    vif.tx=1'b0;
    #(baud_period * 20);
    $display("data to send = %h" , t.data);
    for(int i =0 ; i<8 ; i++)begin
      vif.tx = t.data[i];
      #(baud_period*20);
    end
    if(t.parity_type!=2'b00)begin
      vif.tx=parity_bit;
      #(baud_period*20);
    end
    vif.tx=1'b1;
    #(baud_period * 20);
  endtask //

  task receive_byte(output [7:0] data_recieved);
      @(negedge vif.rx);
      #((baud_period *20)/2);

      for (int i =0 ;i<8 ;i++ ) begin
        #(baud_period*20);
        data_recieved[i]=vif.rx;
      end

    #(baud_period*20);      
  endtask 

  task send_corrupted_byte(input UART_transaction t);
    bit parity_bit;
        // Calculate parity based on the transaction
        case (t.parity_type)
            2'b01: parity_bit = ^t.data;    // Odd Parity
            2'b10: parity_bit = ~^t.data;   // Even Parity
            default: parity_bit = 1'b1; // Default for no parity
        endcase
    vif.tx=1'b0;
    #(baud_period*20);

    for (int i =0 ;i<8 ;i++ ) begin
      vif.tx=t.data[i];
      #(baud_period*20);
      $display("BFM: sending bits");
    end
    if(t.parity_type!=2'b00)begin
      vif.tx=parity_bit;
      #(baud_period*20);
    end

    vif.tx=1'b0;
    #(baud_period*20);


  endtask //

   task run_serial_burst_test(int num_bursts = 20 , UART_sb scb);
        $display("--- [BFM] Starting SERIAL Random Burst Test ---");
        repeat(num_bursts) begin
            // Randomize properties for the entire burst
            assert(this.trans.randomize());

            $display("[BFM] Starting Burst: Parity=%b", this.trans.parity_type);

            // The testbench needs to tell the DUT what parity to expect
            // This happens outside the BFM, but we model that the transaction has this property
            // We pass the whole transaction to send_byte now

            for (int i = 0; i <8; i++) begin
                assert(this.trans.randomize(data));
                scb.tx_mailbox.put(this.trans.data);

                // Send the byte serially using the corrected send_byte task
                send_byte(this.trans);

                // Sample coverage on the transaction we just sent
                this.cg_inst.sample(this.trans);
                $display("  [BFM] Sent Byte %0d: data=%h", i+1, this.trans.data);
            end
        end
        $display("--- [BFM] SERIAL Random Burst Test Finished ---");
    endtask



endclass //UART_bfm

endpackage