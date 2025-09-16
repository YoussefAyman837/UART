package UART_sb_pkg;
class UART_sb;
mailbox #(byte) tx_mailbox;
mailbox #(byte) rx_mailbox;
  function new();
    tx_mailbox = new();
    rx_mailbox = new();
  endfunction //new()

  task  run();
    byte tx_data , rx_data; 
    forever begin
      tx_mailbox.get(tx_data);
      rx_mailbox.get(rx_data);
      if(tx_data == rx_data)begin
        $display("scoreboard PASS tx_data = %h , rx_data = %h" , tx_data , rx_data);
      end
      else begin
        $display("scoreboard FAILS tx_data = %h , rx_data = %h" , tx_data , rx_data);
      end
    end
  endtask //
endclass //UART_sb
endpackage