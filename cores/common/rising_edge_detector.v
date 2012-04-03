//                              -*- Mode: Verilog -*-
// Filename        : falling_edge_detector.v
// Description     : Single Bit Falling Edge Detector
// Author          : Phil Tracton
// Created On      : Sat Mar 17 21:08:48 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!


module rising_edge_detector(
			    input wire clk_i,
			    input wire rst_i,
			    
			    input wire signal,
			    
			    output reg detected
			    );
    
    reg 			       delay;    
    
    always @(posedge clk_i)
      if (rst_i)
	delay <= 1'b0;
      else
	delay <= signal;    
    
    always @(posedge clk_i)
      if (rst_i)
	detected <= 1'b0;
      else
	if (!delay & signal)
	  detected <= 1'b1;    
    
    
endmodule // rising_edge_detector
