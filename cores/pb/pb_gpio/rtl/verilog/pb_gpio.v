//                              -*- Mode: Verilog -*-
// Filename        : pb_gpio.v
// Description     : Picoblaze GPIO
// Author          : Phil Tracton
// Created On      : Mon Mar 12 13:31:48 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

module pb_gpio(
	       input wire clk_i,
	       input wire rst_i,

	       inout wire [7:0] gpio,

	       input wire [7:0] gpio_oe,
	       input wire [7:0] gpio_enable,
	       input wire [7:0] gpio_data_i,   //Written by FW
	       output reg [7:0] gpio_data_o,   //Read by FW
	       output reg int_o
	       );

   //
   // GPIO as an output, if the OE (output enable) bit is high, drive gpio_data_o out.  Else tri-state the signal so that it can
   // be driven to this module
   //
   assign 	      gpio[0] = (gpio_oe[0] & gpio_enable[0]) ? gpio_data_i[0] : 1'bz;
   assign 	      gpio[1] = (gpio_oe[1] & gpio_enable[1]) ? gpio_data_i[1] : 1'bz;
   assign 	      gpio[2] = (gpio_oe[2] & gpio_enable[2]) ? gpio_data_i[2] : 1'bz;
   assign 	      gpio[3] = (gpio_oe[3] & gpio_enable[3]) ? gpio_data_i[3] : 1'bz;
   assign 	      gpio[4] = (gpio_oe[4] & gpio_enable[4]) ? gpio_data_i[4] : 1'bz;
   assign 	      gpio[5] = (gpio_oe[5] & gpio_enable[5]) ? gpio_data_i[5] : 1'bz;
   assign 	      gpio[6] = (gpio_oe[6] & gpio_enable[6]) ? gpio_data_i[6] : 1'bz;
   assign 	      gpio[7] = (gpio_oe[7] & gpio_enable[7]) ? gpio_data_i[7] : 1'bz;

   //
   // GPIOs as inputs.  If OE (output enable) is not asserted, and the input value as a way to capture it
   // 
   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[0] <= 1'b0;
     else
       gpio_data_o[0] <= !gpio_oe[0] & gpio[0] & gpio_enable[0];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[1] <= 1'b0;
     else
       gpio_data_o[1] <= !gpio_oe[1] & gpio[1] & gpio_enable[1];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[2] <= 1'b0;
     else
       gpio_data_o[2] <= !gpio_oe[2] & gpio[2] & gpio_enable[2];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[3] <= 1'b0;
     else
       gpio_data_o[3] <= !gpio_oe[3] & gpio[3] & gpio_enable[3];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[4] <= 1'b0;
     else
       gpio_data_o[4] <= !gpio_oe[4] & gpio[4] & gpio_enable[4];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[5] <= 1'b0;
     else
       gpio_data_o[5] <= !gpio_oe[5] & gpio[5] & gpio_enable[5];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[6] <= 1'b0;
     else
       gpio_data_o[6] <= !gpio_oe[6] &  gpio[6] & gpio_enable[6];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[7] <= 1'b0;
     else
       gpio_data_o[7] <= !gpio_oe[7] & gpio[7] & gpio_enable[7];   

   //
   // Interrupt on a rising or falling edge for inputs on any of the bits if the interrupt is enabled
   //

   wire 	      int_rising = (!gpio_oe[0]) ? gpio[0] & !gpio_data_o[0]  & gpio_enable[0]:
		      (!gpio_oe[1]) ? gpio[1] & !gpio_data_o[1]  & gpio_enable[1]:
		      (!gpio_oe[2]) ? gpio[2] & !gpio_data_o[2]  & gpio_enable[2]:
		      (!gpio_oe[3]) ? gpio[3] & !gpio_data_o[3]  & gpio_enable[3]:
		      (!gpio_oe[4]) ? gpio[4] & !gpio_data_o[4]  & gpio_enable[4]:
		      (!gpio_oe[5]) ? gpio[5] & !gpio_data_o[5]  & gpio_enable[5]:
		      (!gpio_oe[6]) ? gpio[6] & !gpio_data_o[6]  & gpio_enable[6]:
		      (!gpio_oe[7]) ? gpio[7] & !gpio_data_o[7]  & gpio_enable[7]: 1'b0;
   
   wire 	      int_falling = (!gpio_oe[0]) ? !gpio[0] & gpio_data_o[0]  & gpio_enable[0]:
		      (!gpio_oe[1]) ? !gpio[1] & gpio_data_o[1]  & gpio_enable[1]:
		      (!gpio_oe[2]) ? !gpio[2] & gpio_data_o[2]  & gpio_enable[2]:
		      (!gpio_oe[3]) ? !gpio[3] & gpio_data_o[3]  & gpio_enable[3]:
		      (!gpio_oe[4]) ? !gpio[4] & gpio_data_o[4]  & gpio_enable[4]:
		      (!gpio_oe[5]) ? !gpio[5] & gpio_data_o[5]  & gpio_enable[5]:
		      (!gpio_oe[6]) ? !gpio[6] & gpio_data_o[6]  & gpio_enable[6]:
		      (!gpio_oe[7]) ? !gpio[7] & gpio_data_o[7]  & gpio_enable[7]: 1'b0;
     
   always @(posedge clk_i)
     if (rst_i)
       int_o <= 1'b0;
     else
       int_o = int_rising | int_falling;
   
endmodule // pb_gpio
