
initial
  begin
      `TB.simulation_start;
            
      @(negedge `TB.reset_tb);
      $display("RESET RELEASED @ %d", $time);

      repeat(1000) @(posedge `TB.clk_tb);

      `TB.simulation_pass;   
      
  end
      