# UART Transmitter and Receiver (Verilog)

This project implements a Universal Asynchronous Receiver/Transmitter (UART) module in Verilog, including both transmitter (TX) and receiver (RX) components. It also includes a SystemVerilog testbench for simulation and verification.

## 📌 Features

- Configurable baud rate
- 8-bit data transmission
- 1 start bit, 1 stop bit (8N1 format)
- Transmitter-ready and receiver-ready handshaking
- Baud rate tick generation based on system clock
- Modular design with `UART_tx`, `UART_rx`, and `UART_top` modules

## ⚙️ Configuration

- **Clock Frequency:** 50 MHz
- **Baud Rate:** Configurable via parameter (e.g., 9600 bps)
- **Baud Tick Generator:** Generates a tick every `CLK_FREQ / BAUD_RATE` cycles

## ▶️ How to Simulate

1. Open your simulator (e.g.,QuestaSim, ModelSim, VCS, Icarus Verilog).
2. Compile the RTL and testbench files.
3. Run the simulation and observe the waveform or console output.
