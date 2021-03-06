//                              -*- Mode: Verilog -*-
// Filename        : picoblaze.v
// Description     : Picoblaze SOC Top Level
// Author          : Phil Tracton
// Created On      : Tue Mar  6 17:15:09 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

module picoblaze(
		 input wire clk_pad,
		 input wire rst_pad,
		 
		 output wire uart_tx_pad,
		 input wire uart_rx_pad
		 );
    
    
    //
    // System Controller is the central point for cleaning up the input clock and reset signals 
    //
    
    wire 		    clk_i;          //GLOBAL Clock for all modules
    wire 		    rst_i;          //GLOBAL Reset for all modules (synchronous reset)
    
    system_controller sys_con(
			      .clk_pad(clk_pad),
			      .rst_pad(rst_pad),
			      
			      .clk_o(clk_i),
			      .rst_o(rst_i),
			      .locked()
			      );
    
    //
    // Embedded_kcpsm3 is the Picoblaze CPU and Instruction ROM
    //
    
    wire 		    cpu_int_i;      //CPU Interrupt
    wire [7:0] 		    cpu_data_i;      //CPU Data In from registers
    wire [7:0] 		    cpu_data_o;      //CPU Data out to registers
    wire [7:0] 		    cpu_addr_o;     //CPU Address bus for registers
    wire 		    cpu_rd_o;       //CPU Read Strobe for registers
    wire 		    cpu_wr_o;       //CPU Write Strobe for registers
    wire 		    cpu_inta_o;     //CPU Interrrupt Acknowledge
    
    
    embedded_kcpsm3 cpu(
			.port_id(cpu_addr_o),
			.write_strobe(cpu_wr_o),
			.read_strobe(cpu_rd_o),
			.out_port(cpu_data_o),
			.in_port(cpu_data_i),
			.interrupt(cpu_int_i),
			.interrupt_ack(cpu_inta_o),
			.reset(rst_i),
			.clk(clk_i)
			);
    
    
    //
    // UART 
    //
    // For serial communiation back to the PC
    //
    
    wire [7:0] 		    uart_baud_control;  //FW reg to control the baurdate
    wire [7:0] 		    uart_baud_count;    //FW reg to set the count for the baurdare
    wire [7:0] 		    uart_baud_status;   //FW reg to read the status of the baud generator
    
    wire [7:0] 		    uart_tx_data;       //FW reg to write data out the UART
    wire 		    uart_tx_int;        //UART Transmit Interrupt, buffer full or half full
    wire 		    uart_tx_write;      //UART Transmit Write, a signal to write data into the FIFO
    wire [7:0] 		    uart_tx_control;    //FW reg to control the UART Transmitter
    
    wire [7:0] 		    uart_fifo_status;   //FW reg to see the status of the TX and RX FIFOs
    
    
    wire [7:0] 		    uart_rx_data;       //FW reg to read the data received by the UART
    wire 		    uart_rx_int;        //UART Receiver Interrupt, any data, half full FIFO or full FIFO
    wire 		    uart_rx_read;       //UART Receiver Read, a signal to read data from the FIFO
    
    uart uart_inst(
		   .clk_i(clk_i),
		   .rst_i(rst_i),
		   
		   //
		   // UART Baud
		   //
		   .uart_baud_control(uart_baud_control),
		   .uart_baud_count(uart_baud_count),
		   .uart_baud_status(uart_baud_status),
		   
		   //
		   // UART Transmit
		   //
		   .uart_tx_pad(uart_tx_pad), 
		   .uart_tx_data(uart_tx_data),
		   .uart_tx_int(uart_tx_int),
		   .uart_tx_write(uart_tx_write), 
		   .uart_tx_control(uart_tx_control),
		   
		   .uart_fifo_status(uart_fifo_status),
		   
		   //
		   // UART Receive
		   //
		   .uart_rx_pad(uart_rx_pad),
		   .uart_rx_data(uart_rx_data),
		   .uart_rx_int(uart_rx_int),
		   .uart_rx_read(uart_rx_read)
		   );
    
    
    //
    // Until we build a real interrupt handler!
    //
    wire [7:0] 		    int_src ={5'b0, uart_tx_int, uart_rx_int};
    wire [7:0] 		    int_mask;
    wire [7:0] 		    int_clear;
    wire [7:0] 		    interrupts;
    
    interrupts irq_controller(
			      .clk_i(clk_i),
			      .rst_i(rst_i),
			      .int_src(int_src),
			      .int_mask(int_mask),
			      .int_clear(int_clear),
			      .interrupts(interrupts),
			      .int_o(cpu_int_i)
			      );    
    
    //
    // REGISTERS
    //
    // This is the register file for all FW accessible registers in the system
    //
    
    registers register_file(
			    //
			    // System Signals
			    //
			    .clk_i(clk_i),
			    .rst_i(rst_i),

			    .sim_status(),
			    
			    //
			    // Bus Signals
			    //
			    .addr_i(cpu_addr_o),
			    .data_i(cpu_data_o),
			    .rd_i(cpu_rd_o),
			    .wr_i(cpu_wr_o),		 
			    .data_o(cpu_data_i),

			    //
			    // Interrupt Controller
			    //
			    .int_mask(int_mask),
			    .int_clear(int_clear),
			    .interrupts(interrupts),
		 	    
			    //
			    // UART
			    //
			    .uart_baud_control(uart_baud_control),
			    .uart_baud_count(uart_baud_count),
			    .uart_baud_status(uart_baud_status),
			    .uart_tx_data(uart_tx_data),
			    .uart_tx_control(uart_tx_control),
			    .uart_fifo_status(uart_fifo_status),
			    .uart_rx_data(uart_rx_data),
			    .uart_tx_write(uart_tx_write),
			    .uart_rx_read(uart_rx_read)
			    
			    );      

endmodule // picoblaze

   