package UART_trx_pkg;

class UART_transaction;

rand logic [7:0] data ; 
rand logic [1:0] parity_type;
  function new();

  endfunction //new()
endclass //UART_transaction
endpackage