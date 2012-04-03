//                              -*- Mode: Verilog -*-
// Filename        : baudrate.v
// Description     : Baudrate generate for the UART
// Author          : Phil Tracton
// Created On      : Fri May 14 10:22:55 2010
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

module baudrate(
		input wire clk_i,
		input wire rst_i,
		input wire [7:0] control,
		input wire [7:0] count,
		output wire [7:0] status,
		output wire baudrate
		);
   
   wire 	       count_done;	
   reg [7:0] 	       internal_count;
   
   assign 	       count_done = ((count == internal_count) & (internal_count != 'b0));
   assign 	       baudrate = count_done;	
   assign 	       status = {6'b0, baudrate, count_done};	
   
   
   always @(posedge clk_i)
     if (rst_i)
       internal_count <= 'b0;
     else
       begin
	  if (count_done)
	    internal_count <= 'b0;						
	  else if (control[7])
	    internal_count <= internal_count + 1;
	  else
	    internal_count <= 'b0;
       end // else: !if(reset)
   
   
endmodule // pb_baudrate
