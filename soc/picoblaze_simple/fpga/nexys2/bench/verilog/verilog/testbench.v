
`include "timescale.v"
module testbench;
  
    //
    // Free Running 50 MHz clock
    //
    parameter _clk_50mhz_high = 10,
		_clk_50mhz_low  = 10,
		_clk_50mhz_period = _clk_50mhz_high + _clk_50mhz_low;
    
    reg clk_tb;	
    
    initial
      begin
	  clk_tb <= 'b0;
	  forever
	    begin
		#(_clk_50mhz_low)  clk_tb = 1;
		#(_clk_50mhz_high) clk_tb = 0;	     
	    end	
      end
    
    //
    // Global Asynch reset, KEY[3] on the board is ACTIVE LOW
    //
    reg 	     reset_tb; 
    
    initial
      begin
	  reset_tb = 0;
	  #1    reset_tb = 1;
	  #2000 reset_tb = 0;
      end


    
    //
    // DUT to test
    //
    wire clk_o;
    wire rst_o;
    wire locked;
    
    system_controller dut(
			 .clk_pad(clk_tb),
			 .rst_pad(reset_tb),

			 .clk_o(clk_o),
			 .rst_o(rst_o),

			 .locked(locked)
			 );    
   
    //
    // Dump signals for waveform viewing
    //
    dump dump();


    //
    // Testbench controlling tasks
    //
`include "testbench_tasks.v"
    
    //
    // Include external thread for testing
    //
`include "stimulus.v"
        
endmodule // testbench
