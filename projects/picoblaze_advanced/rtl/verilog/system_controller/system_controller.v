//                              -*- Mode: Verilog -*-
// Filename        : system_controller.v
// Description     : S3 Picoblaze System Controller
// Author          : Phil Tracton
// Created On      : Fri May 14 09:27:40 2010
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

module system_controller(
			 input wire clk_pad,
			 input wire rst_pad,

			 output wire clk_o,
			 output reg rst_o,

			 output wire locked
			 );

    wire 			     clk_ibufg_o;
    wire 			     clk_bufg_o;
    wire 			     clk_dcm_o;
    
    reg 			     rst_dcm;
    reg [7:0] 			     delay_rst_o;
  
    
    //
    // Input Buffer for the clock
    //
    IBUFG IBUFG_0(
		  .O(clk_ibufg_o), 
		  .I(clk_pad) 
		  );
    
    //
    // Low skew clock lines for distributing the clock to the rest
    // of the system
    //    
    BUFG bufg_clk(
		  .O (clk_o),
		  .I (clk_dcm_o)
		  );

    //
    // Low skew feedback line to the DCM
    //
    BUFG bufg_clkfb(
		    .O (clk_bufg_o),
		    .I (clk_dcm_o)
		    );
    
    
    //
    // Digital Clock Manager
    //   
    DCM DCM_0(
	      .CLK0 (clk_dcm_o),
	      .CLK180 (),
	      .CLK270 (),
	      .CLK2X (),
	      .CLK2X180 (),
	      .CLK90 (),
	      .CLKDV (),
	      .CLKFX (),
	      .CLKFX180 (),
	      .LOCKED (locked),
	      .PSDONE (),
	      .STATUS (),
	      .CLKFB (clk_bufg_o),
	      .CLKIN (clk_ibufg_o),
	      .DSSEN (1'b0),
	      .PSCLK (1'b0),
	      .PSEN (1'b0),
	      .PSINCDEC (1'b0),
	      .RST (rst_dcm)
	      );
    

    //
    // If the dcm lock signal goes from high to low, reset the DCM
    //
    wire 			     lost_dcm_lock;    
    falling_edge_detector dcm_lock_falling(
					   .clk_i(clk_ibufg_o),
					   .rst_i(rst_pad),
					   
					   .signal(locked),
					   
					   .detected(lost_dcm_lock)
					   );

    reg [7:0] 			     rst_dcm_delay;    
    always @(posedge clk_ibufg_o)
      if (rst_pad)
	begin
	    rst_dcm <= 1'b1;
	    rst_dcm_delay <= 'b0;	    
	end
      else
	begin
	    if (lost_dcm_lock & (rst_dcm_delay != 'b0))
	      begin
		  rst_dcm <= 1'b1;
		  rst_dcm_delay <= 'b0;	    
	      end	  
	    if (rst_dcm_delay > 8'h0F)
	      rst_dcm <= 1'b0;
	    
	    if (! (&rst_dcm_delay))
	      rst_dcm_delay <= rst_dcm_delay +1;    
	end // else: !if(rst_pad)
    
    
    always @(posedge clk_ibufg_o)
      if (rst_pad)
	begin
	    rst_o <= 1'b1;
	    delay_rst_o <= 8'b0;	    
	end
      else
	if (&delay_rst_o & locked)
	  rst_o <= 1'b0;
	else
	  delay_rst_o <= delay_rst_o +1;

    
    
endmodule // system_controller
