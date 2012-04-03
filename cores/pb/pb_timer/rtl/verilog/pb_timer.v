//                              -*- Mode: Verilog -*-
// Filename        : pb_timer.v
// Description     : Picoblaze based timer
// Author          : Phil Tracton ptracton@gmail.com
// Created On      : Tue Aug 21 19:27:44 2007
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!


module pb_timer(
		input wire        clk_i,
		input wire        rst_i,
		input wire [7:0]  timer_control,
		input wire [15:0] timer_limit,          // Write an N-1 value for timer if you want N clocks
		output reg [7:0]  timer_status,
		output reg [15:0] timer_count,          // Never let this be a 0 from FW, 1 is a minimum value!
		output reg        timer_disable,        // When asserted, the register file should clear timer_control[7]
		output reg        int_o
		);

    //
    // timer_enabled is just a way to indicate the functionality of timer_control[7]
    //
    wire 			  timer_enabled = timer_control[7];   

    //
    // timer_single_shot is just a way to indicate the functionality of timer_control[6]
    //    
    wire 			  timer_single_shot = timer_control[6];

    //
    // timer_done is checking the current running count against the limit
    // once our running counter is at or beyond the limit, it goes high
    // and stays high until the counter restarts
    //
    wire 			  timer_done = (timer_count >= timer_limit) & timer_enabled;
   
    //
    // timer_pre_scale is just a way to indicate the functionality of timer_control[2:0]
    //
   wire [2:0] 			  timer_pre_scale = timer_control[2:0];
   reg [2:0] 			  timer_pre_scale_counter;
   wire 			  timer_pre_scale_counter_done =  (timer_pre_scale_counter >=  timer_pre_scale);
   
    //
    // If timer_pre_scale_done then the pre_scale_counter is set back to 0.  If timer_pre_scale is
    // non-zero, we start counting.  This is used to slow the count for the timer counter and allows
    // a larger range of values to be measured
    //
    always @(posedge clk_i)
      if (rst_i)
	timer_pre_scale_counter <= 3'h0;
      else
	if (timer_pre_scale_counter_done)
	  timer_pre_scale_counter <= 3'h0;
	else
	  if ( |timer_pre_scale & timer_enabled)
	    timer_pre_scale_counter <= 	timer_pre_scale_counter +1;
    
    //
    // timer status is our status register that FW can read.  The register control
    // block handles the actual bus interfacing, not the local block
    // 
    always @(posedge clk_i)
      if (rst_i)
	timer_status <= 8'h0;
      else
	timer_status <= {6'b0, timer_done, int_o};    

    //
    // int_o is our interrupt to the CPU.  If the timer is enabled, and the count has reached
    // its limit, assert the interrupt
    //
    always @(posedge clk_i)
      if (rst_i)
	int_o <= 1'b0;
      else
	int_o <= timer_enabled ? timer_done : 1'b0;	

    //
    // timer disable is used when in single shot mode and the timer expires, assert this bit
    // to tell the register file to clear the time_control[7] bit
    //
    always @(posedge clk_i)
      if (rst_i)
	timer_disable <= 1'b0;
      else
	timer_disable <= timer_single_shot ? timer_done : 1'b0;    
    
    //
    // This is the counting block. If we are enabled and done, clear the counter, else increment the counter
    // If we are not enabled, keep the counter at 0
    // 
    always @(posedge clk_i)
      if (rst_i)
	timer_count <= 'b0;
      else
	begin
	    if (timer_enabled)
	      begin
		  if (timer_done & timer_pre_scale_counter_done)
		    timer_count <= 'b0;
		  else if (timer_pre_scale_counter_done)
		    timer_count <= timer_count + 1;
	      end
	    else
	      timer_count <= 'b0;			
	end // else: !if(reset)	
    
endmodule // pb_timer

