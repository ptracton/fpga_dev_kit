initial
  begin
     testbench.thread_fail <= 1'b0;
     testbench.thread_pass <= 1'b0;

     @(posedge testbench.leds_tb[0]);
     if (testbench.leds_tb != 8'h01)
       begin
	  $display("LED 0  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

    @(posedge testbench.leds_tb[1]);
     if (testbench.leds_tb != 8'h02)
       begin
	  $display("LED 1  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

    @(posedge testbench.leds_tb[2]);
     if (testbench.leds_tb != 8'h04)
       begin
	  $display("LED 2  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

    @(posedge testbench.leds_tb[3]);
     if (testbench.leds_tb != 8'h08)
       begin
	  $display("LED 3  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

    @(posedge testbench.leds_tb[4]);
     if (testbench.leds_tb != 8'h10)
       begin
	  $display("LED 4  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

    @(posedge testbench.leds_tb[5]);
     if (testbench.leds_tb != 8'h20)
       begin
	  $display("LED 5  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

    @(posedge testbench.leds_tb[6]);
     if (testbench.leds_tb != 8'h40)
       begin
	  $display("LED 6  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

    @(posedge testbench.leds_tb[7]);
     if (testbench.leds_tb != 8'h80)
       begin
	  $display("LED 7  SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end

     @(posedge |testbench.leds_tb);
     if (testbench.leds_tb != 8'hFF)
       begin
	  $display("LED ALL SHOULD BE ON %d @ %d", testbench.leds_tb, $time);	  
	  testbench.thread_fail <= 1'b1;
       end     

     $display("THREAD DONE @ %d", $time);     
     testbench.thread_pass <= 1'b1;      
      
  end
    