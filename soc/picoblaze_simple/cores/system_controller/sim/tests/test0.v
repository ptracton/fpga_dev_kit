
time start;
time stop;
time diff;

initial
  begin
      `TB.simulation_start;
            
      @(negedge `TB.reset_tb);
      $display("RESET RELEASED @ %d", $time);

      //
      // TEST 1 -- Measure time to DCM LOCK
      //
      $display("TEST 1 -- Time to DCM Lock @ %d", $time);      
      start = $time;
      @(posedge `TB.locked);
      stop = $time;
      diff = stop - start;
      $display("DCM Lock took %d @ %d", diff, $time);

      //
      // TEST 2 -- Time to Reset release
      //
      $display("TEST 2 -- Time to RESET RELEASE @ %d", $time);
      @(negedge `TB.rst_o);
      stop = $time;
      diff = stop - start;
      $display("Reset Release took %d @ %d", diff, $time);

      // 255 * 20ns = 5100 ns
      if (diff < 5100)
	begin
	    $display("FAIL: RESET Released too early!");	    
	    `TB.simulation_thread_fail;	    
	end

      //
      // TEST 3 -- Loose DCM Lock
      //
      $display("TEST 3 -- Loose DCM Lock @ %d", $time);
      repeat(10) @(posedge `TB.clk_tb);
      force `TB.clk_tb = 0;
      #12       force `TB.clk_tb = 1;
      #22       force `TB.clk_tb = 0;
      #42       force `TB.clk_tb = 1;
      #4        force `TB.clk_tb = 0;
      #13       force `TB.clk_tb = 1;
      #114       force `TB.clk_tb = 0;
      #76       force `TB.clk_tb = 1;
      #20       force `TB.clk_tb = 0;
      #22       force `TB.clk_tb = 1;
      #32       force `TB.clk_tb = 0;      
      
      if (`TB.locked == 1)
	begin
	    $display("STILL LOCKED!");
	    `TB.simulation_thread_fail;	    
	end
      release `TB.clk_tb;	    
      start = $time;
      @(posedge `TB.locked);
      stop = $time;
      diff = stop - start;
      $display("DCM Lock took %d @ %d", diff, $time);
      
      `TB.simulation_pass;   
      
  end
    