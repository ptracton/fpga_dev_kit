initial
  begin
     testbench.thread_fail <= 1'b0;
     testbench.thread_pass <= 1'b0;

     @(posedge `DUT.register_file.sim_status[1]);
     testbench.switches_tb <= 8'h01;
     $display("Assert Switch %d @ %d", testbench.switches_tb, $time);
     repeat(5) @(posedge testbench.clk_tb);
     testbench.switches_tb <= 8'h00;     
     
     
     
     #10 $display("THREAD DONE @ %d", $time);     
     testbench.thread_pass <= 1'b1;      
      
  end