//                              -*- Mode: Verilog -*-
// Filename        : pb_soc_register.v
// Description     : Picoblaze SOC Register File
// Author          : Phil Tracton
// Created On      : Sat Mar 17 22:19:29 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

module pb_soc_registers(
			//
			// System Signals
			//
			input wire clk_i,
			input wire rst_i,
			
			//
			// Test Bench/Simulations 
			//
			output reg [7:0] sim_status,
			
			//
			// Bus Signals
			//
			input wire [7:0] addr_i,
			input wire [7:0] data_i,
			input wire rd_i,
			input wire wr_i,		 
			output reg [7:0] data_o,
			
			//
			// Interrupt Controller
			//
			input wire [7:0] interrupts,
			output reg [7:0] int_mask,
			output reg [7:0] int_clear,

			//
			// LEDS GPIO
			//
			output reg [7:0] leds_gpio_oe,
			output reg [7:0] leds_gpio_enable,
			output reg [7:0] leds_gpio_data_i,
			input wire [7:0] leds_gpio_data_o,
						
			//
			// SWITCHES GPIO
			//
			output reg [7:0] switches_gpio_oe,
			output reg [7:0] switches_gpio_enable,
			output reg [7:0] switches_gpio_data_i,
			input wire [7:0] switches_gpio_data_o,			
			
			//
			// UART
			//
			output reg [7:0] uart_baud_control,
			output reg [7:0] uart_baud_count,
			input wire [7:0] uart_baud_status,      //Read Only!
			output reg [7:0] uart_tx_data,
			output reg [7:0] uart_tx_control,
			input wire [7:0] uart_fifo_status,     //Read Only!
			input wire [7:0] uart_rx_data,         //Read Only!
			output reg uart_tx_write,
			output reg uart_rx_read
			
			);
    
    
    //UART Registers
`define UART_BAUD_CONTROL 8'h00
`define UART_BAUD_COUNT   8'h01
`define UART_BAUD_STATUS  8'h02
`define UART_TX_DATA      8'h03
`define UART_TX_CONTROL   8'h04
`define UART_FIFO_STATUS  8'h05
`define UART_RX_DATA      8'h06
    
    //Interrupt Controller Registers
`define INT_MASK          8'h1B
`define INT_STATUS        8'h1C
`define INT_CLEAR         8'h1D

   //
   // LEDS GPIO
   //
`define LEDS_GPIO_OE     8'h08
`define LEDS_GPIO_ENABLE 8'h09
`define LEDS_GPIO_DATA_I 8'h0A
`define LEDS_GPIO_DATA_O 8'h0B

   //
   // SWITCHES GPIO
   //
`define SWITCHES_GPIO_OE     8'h0C
`define SWITCHES_GPIO_ENABLE 8'h0D
`define SWITCHES_GPIO_DATA_I 8'h0E
`define SWITCHES_GPIO_DATA_O 8'h0F

   
    //
    // Testbench/Simulation Control
    //
`define SIM_STATUS        8'hFF
    
   always @(posedge clk_i)
     if (rst_i)
       uart_tx_write <= 1'b0;
     else
       uart_tx_write <= wr_i & (addr_i == `UART_TX_DATA);
    
    always @(posedge clk_i)
      if (rst_i)
	uart_rx_read <= 1'b0;
      else
	uart_rx_read <= rd_i & (addr_i == `UART_RX_DATA);
    
    
    //    
    // Register Reading
    //
    always @ *
      if (rst_i)
	begin
	    data_o <= 8'b0;	  
	end
      else
	if (rd_i)
	  case (addr_i)
	      `UART_BAUD_CONTROL: data_o <= uart_baud_control;
	      `UART_BAUD_COUNT  : data_o <= uart_baud_count;
	      `UART_BAUD_STATUS : data_o <= uart_baud_status;
	      
	      `UART_TX_DATA     : data_o <= uart_tx_data;
	      `UART_TX_CONTROL  : data_o <= uart_tx_control;
	      `UART_FIFO_STATUS : data_o <= uart_fifo_status;
	      `UART_RX_DATA     : data_o <= uart_rx_data;
	      
	      `INT_MASK         : data_o <= int_mask;
	      `INT_STATUS       : data_o <= interrupts;
	      `INT_CLEAR        : data_o <= int_clear;
	    
	    `LEDS_GPIO_OE     : data_o <= leds_gpio_oe;
	    `LEDS_GPIO_ENABLE : data_o <= leds_gpio_enable;
	    `LEDS_GPIO_DATA_O : data_o <= leds_gpio_data_o;

	    `SWITCHES_GPIO_OE     : data_o <= switches_gpio_oe;
	    `SWITCHES_GPIO_ENABLE : data_o <= switches_gpio_enable;
	    `SWITCHES_GPIO_DATA_O : data_o <= switches_gpio_data_o;	    
	    
	    
	      `SIM_STATUS        : data_o <= sim_status;	     
	      default: data_o <= 8'b0;
	  endcase // case(addr_i)


   /**
    Register Writting
    **/
    always@(posedge clk_i)
      if (rst_i)
	begin
	    uart_baud_control  <= 8'b0;
	    uart_baud_count    <= 8'b0;
	    uart_tx_data       <= 8'b0;
	    uart_tx_control    <= 8'b0;
	    int_clear          <= 8'h0;
	    int_mask           <= 8'hFF;
	    sim_status         <= 8'h00;
	   leds_gpio_oe        <= 8'hFF;
	   leds_gpio_enable    <= 8'hFF;
	   leds_gpio_data_i        <= 8'h00;
	   
	   switches_gpio_oe        <= 8'h00;
	   switches_gpio_enable    <= 8'hFF;
	   switches_gpio_data_i    <= 8'h00;
	   
	end
      else
	if (wr_i)
	  case (addr_i)
	      `UART_BAUD_CONTROL:     uart_baud_control  <= data_i;
	      `UART_BAUD_COUNT:       uart_baud_count    <= data_i;
	      `UART_TX_DATA:          uart_tx_data       <= data_i;
	      `UART_TX_CONTROL:       uart_tx_control    <= data_i;
	      
	      `INT_MASK         : int_mask <= data_i;
	      `INT_CLEAR        : int_clear <= data_i;

	    `LEDS_GPIO_OE     : leds_gpio_oe <= data_i;
	    `LEDS_GPIO_ENABLE : leds_gpio_enable <= data_i;	    
	    `LEDS_GPIO_DATA_I : leds_gpio_data_i <= data_i;

	    `SWITCHES_GPIO_OE     : switches_gpio_oe <= data_i;
	    `SWITCHES_GPIO_ENABLE : switches_gpio_enable <= data_i;
	    `SWITCHES_GPIO_DATA_I : switches_gpio_data_i <= data_i;
	    
	      `SIM_STATUS        : sim_status <= data_i;	 	   	      
	  endcase // case(addr_i)
	else
	  int_clear <= 8'h0;    
    
    
endmodule // pb_soc_registers


