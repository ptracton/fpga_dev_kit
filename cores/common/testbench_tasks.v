
`include "test_defines.v"

//
// Terminate Test
//
reg [31:0] read_word;    
wire       sim_pass;

reg 	thread_pass;
reg     cpu_pass;


wire 	sim_timeout;
reg 	thread_fail;
reg     cpu_fail;
wire 	sim_fail;

integer 	timeout_count;
integer 	timeout_threshold;

//
// If we declare an error or take too long it is a fail
//
assign sim_fail =  sim_timeout | thread_fail | cpu_fail;

//
// The stimulus thread is the only passing signal we need
//
assign sim_pass = thread_pass & cpu_pass;

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
      `TB.simulation_pass;
    
    //
    // If any of the fail cases get tripped, terminate the sim
    //
    always @(posedge sim_fail)
      `TB.simulation_fail;
    
    task simulation_start;
	begin
	    `TB.thread_pass <= 1'b0;
	    `TB.cpu_pass <= 1'b0;
	    `TB.thread_fail <= 1'b0;
	    `TB.cpu_fail <= 1'b0;
	    `TB.timeout_threshold <= 550000;
	    `TB.timeout_count <= 0;
	    
	    if ($value$plusargs("TIMEOUT=%d", timeout_threshold))
	      $display("TIMEOUT = %d", timeout_threshold);	
	end
    endtask // simulation_start
    
    task simulation_finish;
	begin
	    $display("Simulation ran for %d", $time);
	    #50 $finish;	
	end
    endtask // simulation_finish
    
    
    task simulation_pass;
	begin
	    $display("*********************************************************");
	    $display("SIM PASSED @ %d", $time);
	    $display("*********************************************************");
	    `TB.simulation_finish;	
	end
    endtask // simulation_pass
    
    task simulation_thread_fail;
	begin
	    `TB.thread_fail <= 1'b1;
	    $display("THREAD FAILURE @ %d", $time);
	    
	end
    endtask // simulation_thread_fail
    
    
    task simulation_fail;
	begin
	    $display("*********************************************************");	
	    if (thread_fail)
	      $display("FAIL: Test Thread Failure at %d",$time);
	    else if (sim_timeout)
	      $display("FAIL: Timeout  at %d",$time);	
		 else
		   $display("FAIL: Unknown Failure at %d",$time);
	    $display("*********************************************************");
	    `TB.simulation_finish;
	end
    endtask // simulation_fail
    
    

