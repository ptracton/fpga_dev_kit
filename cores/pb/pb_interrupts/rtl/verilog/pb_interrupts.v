//                              -*- Mode: Verilog -*-
// Filename        : interrupts.v
// Description     : Interrupt controller
// Author          : U-BIGGEEK\ptracton
// Created On      : Tue Aug 21 19:21:27 2007
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!


module pb_interrupts(
		     input wire clk_i,
		     input wire rst_i,
		     input wire [7:0] int_src,
		     input wire [7:0] int_mask,
		     input wire [7:0] int_clear,  //Make this a self clearing register 
		     output wire [7:0] interrupts,
		     output reg int_o
		     );
   
   reg [7:0] 		    request;	   
   reg [7:0] 		    int_src_s, int_src_ss;
   integer 		    i;
   
   assign 		    interrupts = request & ~int_mask;

   always @(posedge clk_i)
     if (rst_i)
       int_o <= 1'b0;
     else
       int_o <= |interrupts;   
   
   always @(posedge clk_i)
     if (rst_i)
       begin
	  int_src_s <= 'b0;
	  int_src_ss <= 'b0;	
	  request <= 'b0;			
       end
     else
       begin
	  int_src_s <= int_src;
	  int_src_ss <= int_src_s;
	  
	  for (i =0; i<= 7; i=i+1)
	    begin
	       request[i] <= (int_src_s[i] && !int_src_ss[i]) || request[i] & ~int_clear[i];				  
	    end	  
       end // else: !if(rst_i)
   
   
endmodule // interrupts

