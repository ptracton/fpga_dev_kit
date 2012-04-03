//                              -*- Mode: Verilog -*-
// Filename        : uart.v
// Description     : UART puts together the baud rate, rx and tx modules into a single entity
// Author          : Phil Tracton
// Created On      : Fri May 14 09:52:54 2010
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/********************************************************************************
 $Header:$
 $Author:$
 $Date:$
 $Revision:$
 $State:$
 
 $Log:$
 ********************************************************************************/

module pb_uart(
	       input wire clk_i,
	       input wire rst_i,
	       
	       /**
		UART Baud
		**/
	       input wire [7:0] uart_baud_control,
	       input wire [7:0] uart_baud_count,
	       output wire [7:0]uart_baud_status,
	       
	       /**
		UART Transmit
		**/
	       output wire uart_tx_pad, 
	       input wire [7:0] uart_tx_data,
	       output reg uart_tx_int,
	       input wire uart_tx_write, 
	       input wire [7:0] uart_tx_control,
	       output wire [7:0] uart_fifo_status,
	       /**
		UART Receive
		**/
	       input wire uart_rx_pad,
	       output wire [7:0] uart_rx_data,
	       output reg uart_rx_int,
	       input wire uart_rx_read
	       );
   
   wire 	     baudrate;
   wire 	     rst_tx_i = rst_i | uart_tx_control[1];
   wire 	     rst_rx_i = rst_i | uart_tx_control[1];
   
   
   assign 	     uart_fifo_status[7:5] = 3'b0;
   
   
   always @(posedge clk_i)
     if (rst_i)
       begin
	  uart_tx_int <= 1'b0;
	  uart_rx_int <= 1'b0;	  
       end
     else
       begin
	  uart_tx_int <= uart_fifo_status[0] | uart_fifo_status[1];
	  uart_rx_int <= uart_fifo_status[2] | uart_fifo_status[3] | uart_fifo_status[4];	  
       end
   
   /**
    Calculate the baudrate of the UART
    **/
   baudrate uart_baudrate(
			  .clk_i(clk_i),
			  .rst_i(rst_i),
			  .control(uart_baud_control),
			  .count(uart_baud_count),
			  .status(uart_baud_status),
			  .baudrate(baudrate)
			  );

   uart_tx tx(
	      .data_in(uart_tx_data),
	      .write_buffer(uart_tx_write),
	      .reset_buffer(rst_tx_i),
	      .en_16_x_baud(baudrate),
	      .serial_out(uart_tx_pad),
	      .buffer_full(uart_fifo_status[0]),
	      .buffer_half_full(uart_fifo_status[1]),
	      .clk(clk_i)
	      );
   
   uart_rx rx(
	      .serial_in(uart_rx_pad),
	      .data_out(uart_rx_data),
	      .read_buffer(uart_rx_read),
	      .reset_buffer(rst_rx_i),
	      .en_16_x_baud(baudrate),
	      .buffer_data_present(uart_fifo_status[2]),
	      .buffer_full(uart_fifo_status[3]),
	      .buffer_half_full(uart_fifo_status[4]),
	      .clk(clk_i)
	      );
   
   

   
endmodule // uart
