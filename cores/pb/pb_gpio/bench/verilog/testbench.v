
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

   wire [7:0] gpio;  
   reg [7:0]  gpio_r;   
   reg [7:0]  gpio_oe;   
   reg [7:0]  gpio_data_i;
   reg [7:0]  gpio_enable;   
   wire [7:0] gpio_data_o;   
   wire       int_o;

    initial
      begin
	 gpio_oe     <= 8'b0;
	 gpio_data_i <= 8'b0;
	 gpio_r      <= 8'h0;
	 gpio_enable <= 8'h0;
      end

   //
   // When Output Enabled, the test bench drives Z to let the DUT drive value.  Else the test bench
   // drives value to allow input to the DUT
   //
   assign gpio[0] = (gpio_oe[0]) ? 1'bz : gpio_r[0];
   assign gpio[1] = (gpio_oe[1]) ? 1'bz : gpio_r[1];
   assign gpio[2] = (gpio_oe[2]) ? 1'bz : gpio_r[2];
   assign gpio[3] = (gpio_oe[3]) ? 1'bz : gpio_r[3];
   assign gpio[4] = (gpio_oe[4]) ? 1'bz : gpio_r[4];
   assign gpio[5] = (gpio_oe[5]) ? 1'bz : gpio_r[5];
   assign gpio[6] = (gpio_oe[6]) ? 1'bz : gpio_r[6];
   assign gpio[7] = (gpio_oe[7]) ? 1'bz : gpio_r[7];   
   
   pb_gpio dut(
	       .clk_i(clk_tb),
	       .rst_i(reset_tb),

	       .gpio(gpio),

	       .gpio_oe(gpio_oe),
	       .gpio_data_i(gpio_data_i),
	       .gpio_enable(gpio_enable),
	       .gpio_data_o(gpio_data_o),
	       
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
