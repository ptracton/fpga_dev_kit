

time start;
time stop;
time difference;

initial
  begin
      testbench.thread_pass <= 1'b0;
      testbench.thread_fail <= 1'b0;
      
      @(negedge testbench.reset_tb);
      $display("RESET RELEASED @ %d", $time);

      //
      // Test 0 -- POR Values
      //
     $display("\n\nTEST 0 -- POR Values %d", $time);
      repeat(3) @(posedge testbench.clk_tb);
      if (testbench.timer_status != 8'h00)
	begin
	    $display("TEST 0 FAIL: Timer Status WRONG POR VALUE 0x%x @ %d", testbench.timer_status, $time);
	    testbench.thread_fail <= 1'b1;	
	end

      if (testbench.timer_count != 8'h0)
	begin
	    $display("TEST 0 FAIL: Timer Count WRONG POR VALUE 0x%x @ %d", testbench.timer_count, $time);
	    testbench.thread_fail <= 1'b1;	
	end

      if (testbench.int_o != 1'h0)
	begin
	    $display("TEST 0 FAIL: INT_O  WRONG POR VALUE 0x%x @ %d", testbench.int_o, $time);
	    testbench.thread_fail <= 1'b1;	
	end      

      //
      // Test 1  -- Simple Test Case
      //
      $display("\n\nTEST 1 -- Simple Test Case %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h80;

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != 16*20)
	begin
	    $display("TEST 1 FAIL: Wrong Time should be 320, but is %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00;

      //
      // Test 2 -- Long Test Case
      //
      
      $display("\n\nTEST 2 -- Long Test Case %d", $time);
      repeat(3) @(posedge testbench.clk_tb);
      timer_limit <= 16'h8000;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h80;

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != 16'h8001*20)
	begin
	    $display("TEST 2 FAIL: Wrong Time should be 655380, but is %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00;      

      //
      // Test 3  -- Single Shot
      //
      $display("\n\nTEST 3 -- Single Shot%d", $time);

      repeat(3) @(posedge testbench.clk_tb);
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'hC0;
      start = $time;

      @(posedge testbench.timer_disable);
      timer_control <= 8'h00;      
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != 16*20)
	begin
	    $display("TEST 3 FAIL: Wrong Time should be 320, but is %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      //
      // Test 4 -- Prescalar 1
      //
      $display("\n\nTEST 4 -- Prescalar 1 %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h81;  //enable and prescale by 1

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (16*20*2))
	begin
	    $display("TEST 4 FAIL: Wrong Time %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00;      

      //
      // Test 5 -- Prescalar 2
      //
      $display("\n\nTEST 5 -- Prescalar 2 %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h82;  //enable and prescale by 2

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (16*20*3))
	begin
	    $display("TEST 5 FAIL: Wrong Time %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00;

      //
      // Test 6 -- Prescalar 3
      //
      $display("\n\nTEST 6 -- Prescalar 3 %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h83;  //enable and prescale by 2

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (16*20*4))
	begin
	    $display("TEST 6 FAIL: Wrong Time  %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00;        

      //
      // Test 7 -- Prescalar 4
      //
      $display("\n\nTEST 7 -- Prescalar 4 %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h84;  //enable and prescale by 2

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (16*20*5))
	begin
	    $display("TEST 7 FAIL: Wrong Time  %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00;   

      //
      // Test 8 -- Prescalar 5
      //
      $display("\n\nTEST 7 -- Prescalar 5 %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h85;  //enable and prescale by 2

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (16*20*6))
	begin
	    $display("TEST 8 FAIL: Wrong Time  %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00; 

      //
      // Test 9 -- Prescalar 6
      //
      $display("\n\nTEST 9 -- Prescalar 6 %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h86;  //enable and prescale by 2

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (16*20*7))
	begin
	    $display("TEST 9 FAIL: Wrong Time  %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00; 

      //
      // Test 10 -- Prescalar 7
      //
      $display("\n\nTEST 10 -- Prescalar 7 %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h000F;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h87;  //enable and prescale by 2

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (16*20*8))
	begin
	    $display("TEST 10 FAIL: Wrong Time  %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00; 

      //
      // Test 11 -- REALLY FAST
      //
      $display("\n\nTEST 11 -- Really FAST %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h0001;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h80; 

      @(posedge testbench.int_o);
      start = $time;
      
      @(posedge testbench.int_o);
      stop = $time;
      difference = stop - start;
      $display("TIMER RUN %d ", difference);
      if (difference != (2*20))
	begin
	    $display("TEST 11 FAIL: Wrong Time  %d", difference);
	    testbench.thread_fail <= 1'b1;	
	end

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00; 


      //
      // Test 12 -- Disable in the middle
      //
      $display("\n\nTEST 12 -- Disable in the middle %d", $time);

      repeat(3) @(posedge testbench.clk_tb);      
      timer_limit <= 16'h0001;
      
      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h80; 

     @(posedge testbench.int_o);
     start = $time;
     repeat(3) @(posedge testbench.clk_tb);
     timer_control <= 8'h00;
     repeat(2) @(posedge testbench.clk_tb);

      if (testbench.timer_status != 8'h00)
	begin
	    $display("TEST 12 FAIL: Timer Status WRONG DISABLE VALUE 0x%x @ %d", testbench.timer_status, $time);
	    testbench.thread_fail <= 1'b1;	
	end

      if (testbench.timer_count != 8'h0)
	begin
	    $display("TEST 12 FAIL: Timer Count WRONG DISABLE VALUE 0x%x @ %d", testbench.timer_count, $time);
	    testbench.thread_fail <= 1'b1;	
	end

      if (testbench.int_o != 1'h0)
	begin
	    $display("TEST 12 FAIL: INT_O  WRONG DISABLE VALUE 0x%x @ %d", testbench.int_o, $time);
	    testbench.thread_fail <= 1'b1;	
	end      

      repeat(3) @(posedge testbench.clk_tb);
      timer_control <= 8'h00; 
     
      //
      // All Done, Sim Passed!
      //
      repeat(30) @(posedge testbench.clk_tb);
      testbench.thread_pass <= 1'b1;
      
  end