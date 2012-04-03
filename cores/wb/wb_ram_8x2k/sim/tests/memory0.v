reg [7:0] wb_read;
reg[11:0] i;

initial
  begin
      `TB.simulation_start;
            
      @(negedge `TB.reset_tb);
      $display("RESET RELEASED @ %d", $time);
      
      for (i = 0; i < 2048; i = i +1) 
	begin
	    `TB.write(i[10:0], i[7:0]);
	    @(posedge `TB.clk_tb);
	end
      


      repeat(100) @(posedge `TB.clk_tb);

      for (i = 0; i < 2048; i = i +1) 
	begin
	    `TB.read(i[10:0], i[7:0], wb_read);
	    @(posedge `TB.clk_tb);
	end
      

      `TB.simulation_pass;   
      
  end // initial begin
    