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
      $display("\n\nTESTING MEMORY 8 BIT ACCESS, LSB @ %d", $time);
     
  
      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.write(i[10:0], 4'h1, i);
	    @(posedge `TB.clk_tb);
	end
      
      repeat(100) @(posedge `TB.clk_tb);

      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.read(i[10:0], 4'h1, i[7:0], wb_read);
	    @(posedge `TB.clk_tb);
	end

      //************************************************************************
      $display("\n\nTESTING MEMORY 8 BIT ACCESS, 2nd LSB @ %d", $time);
     
  
      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.write(i[10:0], 4'h2, i[7:0] << 8);
	    @(posedge `TB.clk_tb);
	end
      
      repeat(100) @(posedge `TB.clk_tb);

      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.read(i[10:0], 4'h2, i[7:0] << 8 | i[7:0], wb_read);
	    @(posedge `TB.clk_tb);
	end

      //************************************************************************
      $display("\n\nTESTING MEMORY 8 BIT ACCESS, 2nd MSB @ %d", $time);
     
  
      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.write(i[10:0], 4'h4, i << 16);
	    @(posedge `TB.clk_tb);
	end
      
      repeat(100) @(posedge `TB.clk_tb);

      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.read(i[10:0], 4'h4, i[7:0] << 16 | i[7:0] <<8 | i[7:0], wb_read);
	    @(posedge `TB.clk_tb);
	end

      //************************************************************************
      $display("\n\nTESTING MEMORY 8 BIT ACCESS, MSB @ %d", $time);
     
  
      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.write(i[10:0], 4'h8, i << 24);
	    @(posedge `TB.clk_tb);
	end
      
      repeat(100) @(posedge `TB.clk_tb);

      for (i = 0; i < 2048; i = i +4) 
	begin
	    `TB.read(i[10:0], 4'h8, i[7:0] << 24 |i[7:0] << 16 | i[7:0] <<8 | i[7:0], wb_read);
	    @(posedge `TB.clk_tb);
	end
      

      `TB.simulation_pass;   
      
  end // initial begin
    