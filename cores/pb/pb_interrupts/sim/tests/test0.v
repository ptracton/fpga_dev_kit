
task test_irq;
      input [2:0] index;
      begin
	 $display("TEST IRQ %d @ %d", index, $time);	 
	 testbench.int_mask <= (~1<<index);
	 repeat(3) @(posedge testbench.clk_tb);
	 #13 testbench.int_src <= 1 << index;
	 @(posedge testbench.int_o);
	 #1 if (testbench.interrupts[index] !== 1'b1)
	   begin
	      $display("TEST 1: Fail assert and check interrupt[%d]  0x%x @ %d", index, testbench.interrupts, $time);
	      testbench.thread_fail <= 1'b1;
	   end
	 #5  testbench.int_src <= 'h00;
	 repeat(3) @(posedge testbench.clk_tb);
	 testbench.int_clear <=1 << index;
	 @(negedge testbench.int_o);
	 #1 if (testbench.interrupts[index] !== 1'b0)
	   begin
	      $display("TEST 1: Fail de-assert and check interrupt[%d] 0x%x @ %d", index,testbench.interrupts, $time);
	      testbench.thread_fail <= 1'b1;
	   end
	 repeat(3) @(posedge testbench.clk_tb);
	 int_src <= 8'h0;
	 int_mask <= 8'hFF;
	 int_clear <= 8'h00;	 	 
      end
endtask // test_irq


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
     if (testbench.interrupts != 1'h0)
       begin
	  $display("TEST 0 FAIL: INTERRUPTS  WRONG POR VALUE 0x%x @ %d", testbench.interrupts, $time);
	  testbench.thread_fail <= 1'b1;	
       end       

     //
     // TEST 1 -- Interrupts
     //
     $display("\n\nTEST 1 -- Interrupts %d", $time);
     repeat(3) @(posedge testbench.clk_tb);

     test_irq(3'h0);
     test_irq(3'h1);
     test_irq(3'h2);
     test_irq(3'h3);
     test_irq(3'h4);
     test_irq(3'h5);
     test_irq(3'h6);
     test_irq(3'h7);
     
     

     //
     // All Done, Sim Passed!
     //
     repeat(30) @(posedge testbench.clk_tb);
     testbench.thread_pass <= 1'b1;
     
  end // initial begin
   