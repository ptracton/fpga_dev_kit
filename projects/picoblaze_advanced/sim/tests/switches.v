initial
  begin
     testbench.thread_fail <= 1'b0;
     testbench.thread_pass <= 1'b0;

     @(posedge `DUT.register_file.sim_status[1]);
     testbench.switches_tb <= 8'h01;
     $display("Assert Switch %d @ %d", testbench.switches_tb, $time);     
     @(negedge `DUT.register_file.sim_status[1]);
     testbench.switches_tb <= 8'h00;
     $display("De-assert Switch %d @ %d", testbench.switches_tb, $time);     
     
     #10 $display("THREAD DONE @ %d", $time);     
     testbench.thread_pass <= 1'b1;      
      
  end