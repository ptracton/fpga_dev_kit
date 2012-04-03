
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
   // FPGA to test
   //
   reg [7:0] int_src;
   reg [7:0] int_mask;
   reg [7:0] int_clear;
   wire [7:0] interrupts;
   wire       int_o;   

    initial
      begin
	 int_src <= 8'h0;
	 int_mask <= 8'hFF;
	 int_clear <= 8'h00;	 
      end
    
   pb_interrupts dut(
		     .clk_i(clk_tb),
		     .rst_i(reset_tb),
		     .int_src(int_src),
		     .int_mask(int_mask),
		     .int_clear(int_clear),
		     .interrupts(interrupts),
		     .int_o(int_o)
		     );    
   
    //
    // Terminate Test
    //
    wire       sim_pass;
    
    reg 	thread_pass;
        
    wire 	sim_timeout;
    reg 	sim_fail;
    reg 	thread_fail;    
    wire 	any_fail;

    integer 	timeout_count;
    integer 	timeout_threshold;

    //
    // If we declare an error or take too long it is a fail
    //
    assign any_fail = sim_fail | sim_timeout | thread_fail;

    //
    // The stimulus thread is the only passing signal we need
    //
    assign sim_pass = thread_pass;
    
    //
    // Initialize the test variables and check for command line options
    //
    initial
      begin
	  thread_pass <= 1'b0;	  
	  sim_fail <= 1'b0;
	  timeout_threshold <= 550000;
	  timeout_count <= 0;
		  
	  if ($value$plusargs("TIMEOUT=%d", timeout_threshold))
	    $display("TIMEOUT = %d", timeout_threshold);	
	   
      end

    //
    // Count the number of clocks to make sure we don't go too long
    //
    assign     sim_timeout = timeout_count >= timeout_threshold;   
    always @(posedge clk_tb)
      timeout_count = timeout_count + 1;

    //
    // We passed!
    //
    always @(posedge sim_pass)
      begin
	  $display("*********************************************************");
	  $display("SIM PASSED @ %d", $time);
	  $display("*********************************************************");
	  force testbench.sim_fail = 0;
	  #10 $finish;	  
      end

    //
    // If any of the fail cases get tripped, terminate the sim
    //
    always @(posedge any_fail)
      begin
	  $display("*********************************************************");	
	  if (sim_fail)
	    $display("FAIL: Test Failure at %d",$time);
	  else if (sim_timeout)
	    $display("FAIL: Timeout  at %d",$time);	
	  else
	    $display("FAIL: Unknown Failure at %d",$time);
	  $display("*********************************************************");
	  #10 $finish;
      end // always @ (any_fail)
        
    
    //
    // Dump signals for waveform viewing
    //
    dump dump();
    
    
    //
    // Include external thread for testing
    //
`include "stimulus.v"
        
endmodule // testbench
