reg [7:0] wb_read;
reg[31:0] i;

initial
  begin
      `TB.simulation_start;
            
      @(negedge `TB.reset_tb);
      $display("RESET RELEASED @ %d", $time);
    

      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.write(i[10:0], 4'hF, 0);
	end
      
      //************************************************************************
      $display("\n\nTESTING MEMORY 16 BIT ACCESS, LOWER @ %d", $time);
     
  
      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.write(i[10:0], 4'h3, i[7:0] | i[7:0] << 8);
	    @(posedge `TB.clk_tb);
	end
      
      repeat(100) @(posedge `TB.clk_tb);

      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.read(i[10:0], 4'h3, i[7:0] | i[7:0] << 8, wb_read);
	    @(posedge `TB.clk_tb);
	end

      //************************************************************************
      $display("\n\nTESTING MEMORY 16 BIT ACCESS, UPPER @ %d", $time);
     
  
      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.write(i[10:0], 4'hC, i[7:0] << 24 | i[7:0] << 16);
	    @(posedge `TB.clk_tb);
	end
      
      repeat(100) @(posedge `TB.clk_tb);

      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.read(i[10:0], 4'hC, i[7:0] << 24 |i[7:0] << 16 | i[7:0] <<8 | i[7:0], wb_read);
	    @(posedge `TB.clk_tb);
	end
      

      `TB.simulation_pass;   
      
  end // initial begin
    