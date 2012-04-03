
task drive_data;      
      input [2:0] index;
      begin
	 $display("GPIO DRIVE DATA %d @ %d", index, $time);	 
	 testbench.gpio_oe <=  1<< index;
	 testbench.gpio_enable <= 1 << index;
	 repeat(3) @(posedge testbench.clk_tb);
	 testbench.gpio_data_i[index] <= 1'b1;
	 @(posedge testbench.gpio[index]);
	 if (testbench.gpio[index] !== 1'b1)
	   begin
	      $display("TEST 1 FAIL: Rising gpio[%d] WRONG VALUE 0x%x @ %d", index, testbench.gpio[0], $time);
	      testbench.thread_fail <= 1'b1;	  
	   end
	 repeat(3) @(posedge testbench.clk_tb);
	 testbench.gpio_data_i[index] <= 1'h0;
	 @(negedge testbench.gpio[index]);
	 if (testbench.gpio[index] !== 1'b0)
	   begin
	      $display("TEST 1 FAIL: Falling gpio[%d] WRONG VALUE 0x%x @ %d", index, testbench.gpio[0], $time);
	      testbench.thread_fail <= 1'b1;	  
	   end
	 repeat(3) @(posedge testbench.clk_tb);     
      end
endtask // drive_data


task capture_data;      
      input [2:0] index;
      begin
	 $display("GPIO CAPTURE DATA %d @ %d", index, $time);	 
	 testbench.gpio_oe <= ~(1 << index);
	 testbench.gpio_enable <= 1 << index;
	 repeat(3) @(posedge testbench.clk_tb);
	 testbench.gpio_r <= 1 << index;
	 @(posedge testbench.int_o);
	 #1 if (testbench.gpio_data_o[index] !== 1'b1)
	   begin
	      $display("TEST 2 FAIL: Rising gpio_data_o[%d]  WRONG VALUE 0x%x @ %d", index, testbench.gpio_data_o[0], $time);
	      testbench.thread_fail <= 1'b1;	  
	   end
	 repeat(3) @(posedge testbench.clk_tb);
	 testbench.gpio_r <= 8'h00;	 
	 repeat(3) @(posedge testbench.clk_tb);
	 if (testbench.gpio_data_o[index] !== 1'b0)
	   begin
	      $display("TEST 2 FAIL: Falling gpio_data_o[%d]  WRONG VALUE 0x%x @ %d", index, testbench.gpio_data_o[0], $time);
	      testbench.thread_fail <= 1'b1;	  
	   end	 
      end
endtask // capture_data

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
      if (testbench.int_o != 1'h0)
	begin
	    $display("TEST 0 FAIL: INT_O  WRONG POR VALUE 0x%x @ %d", testbench.int_o, $time);
	    testbench.thread_fail <= 1'b1;	
	end  
      if (testbench.gpio_data_o != 8'h0)
	begin
	    $display("TEST 0 FAIL: gpio_data_o  WRONG POR VALUE 0x%x @ %d", testbench.gpio_data_o, $time);
	    testbench.thread_fail <= 1'b1;	
	end 
      if (testbench.gpio != 8'bz)
	begin
	    $display("TEST 0 FAIL: gpio  WRONG POR VALUE 0x%x @ %d", testbench.gpio, $time);
	    testbench.thread_fail <= 1'b1;	
	end
     
     //
     // Test 1 -- Drive data out, 1 by 1
     //
     $display("\n\nTEST 1 -- Drive Data %d", $time);
     repeat(3) @(posedge testbench.clk_tb);  

     drive_data(3'h0);
     drive_data(3'h1);
     drive_data(3'h2);
     drive_data(3'h3);
     drive_data(3'h4);
     drive_data(3'h5);
     drive_data(3'h6);
     drive_data(3'h7);

     testbench.gpio_oe <= 8'h00;
     testbench.gpio_enable <= 8'h00;
     testbench.gpio_data_i <= 8'h00;
     testbench.gpio_r <= 8'h00;
     
     
     //
     // Test 2 -- Read Data 1 by 1
     //
     $display("\n\nTEST 2 -- Read Data %d", $time);
     repeat(3) @(posedge testbench.clk_tb); 

     capture_data(3'h0);
     capture_data(3'h1);
     capture_data(3'h2);
     capture_data(3'h3);
     capture_data(3'h4);
     capture_data(3'h5);
     capture_data(3'h6);
     capture_data(3'h7);

     
     //
     // All Done, Sim Passed!
     //
     repeat(30) @(posedge testbench.clk_tb);
     testbench.thread_pass <= 1'b1;
     
  end // initial begin
   