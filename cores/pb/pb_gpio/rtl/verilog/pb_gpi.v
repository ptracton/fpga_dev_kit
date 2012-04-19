//                              -*- Mode: Verilog -*-
// Filename        : pb_gpi.v
// Description     : Picoblaze General Purpose Input
// Author          : Phil Tracton
// Created On      : Wed Apr 18 21:44:09 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

module pb_gpi(
	       input wire clk_i,
	       input wire rst_i,

	       input wire [7:0] gpi,

	       input wire [7:0] gpio_enable,
	       output reg [7:0] gpio_data_o,   //Read by FW
	       output reg int_o
	       );

    //
   // GPIOs as inputs.  Capture the input on the enabled channels
   // 
   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[0] <= 1'b0;
     else
       gpio_data_o[0] <= gpi[0] & gpio_enable[0];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[1] <= 1'b0;
     else
       gpio_data_o[1] <= gpi[1] & gpio_enable[1];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[2] <= 1'b0;
     else
       gpio_data_o[2] <= gpi[2] & gpio_enable[2];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[3] <= 1'b0;
     else
       gpio_data_o[3] <= gpi[3] & gpio_enable[3];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[4] <= 1'b0;
     else
       gpio_data_o[4] <= gpi[4] & gpio_enable[4];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[5] <= 1'b0;
     else
       gpio_data_o[5] <= gpi[5] & gpio_enable[5];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[6] <= 1'b0;
     else
       gpio_data_o[6] <=  gpi[6] & gpio_enable[6];

   always @(posedge clk_i)
     if (rst_i)
       gpio_data_o[7] <= 1'b0;
     else
       gpio_data_o[7] <= gpi[7] & gpio_enable[7];   

   //
   // Interrupt on a rising or falling edge for inputs on any of the bits if the interrupt is enabled
   //

   wire 	      int_rising = (gpio_enable[0]) ? gpi[0] & !gpio_data_o[0]:
		      (gpio_enable[1]) ? gpi[1] & !gpio_data_o[1]:
		      (gpio_enable[2]) ? gpi[2] & !gpio_data_o[2]:
		      (gpio_enable[3]) ? gpi[3] & !gpio_data_o[3]:
		      (gpio_enable[4]) ? gpi[4] & !gpio_data_o[4]:
		      (gpio_enable[5]) ? gpi[5] & !gpio_data_o[5]:
		      (gpio_enable[6]) ? gpi[6] & !gpio_data_o[6]:
		      (gpio_enable[7]) ? gpi[7] & !gpio_data_o[7]: 1'b0;
   
   wire 	      int_falling = (!gpio_enable[0]) ? !gpi[0] & gpio_data_o[0]:
		      (gpio_enable[1]) ? !gpi[1] & gpio_data_o[1]:
		      (gpio_enable[2]) ? !gpi[2] & gpio_data_o[2]:
		      (gpio_enable[3]) ? !gpi[3] & gpio_data_o[3]:
		      (gpio_enable[4]) ? !gpi[4] & gpio_data_o[4]:
		      (gpio_enable[5]) ? !gpi[5] & gpio_data_o[5]:
		      (gpio_enable[6]) ? !gpi[6] & gpio_data_o[6]:
		      (gpio_enable[7]) ? !gpi[7] & gpio_data_o[7]: 1'b0;
     
   always @(posedge clk_i)
     if (rst_i)
       int_o <= 1'b0;
     else
       int_o <= int_rising | int_falling;
   
endmodule // pb_gpio
