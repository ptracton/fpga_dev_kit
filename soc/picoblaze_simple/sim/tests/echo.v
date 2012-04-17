

reg [7:0] letter_tx;
reg [7:0] letter_rx;

initial
  begin
     letter_tx <= 8'h41;
     
     @(negedge testbench.reset_tb);      
     $display("Reset Released @ %d", $time);
     `UART_CONFIGURE;

     @(posedge `DUT.register_file.sim_status[0]);     
     repeat(50) @(posedge testbench.clk_tb);
     
     while(letter_tx < 8'h50)
       begin
	  @(posedge testbench.clk_tb);
	  `UART_WRITE_CHAR(letter_tx);
	  letter_tx <= letter_tx + 1;	  
       end   
  end // initial begin
   

initial
  begin
      letter_rx <= 8'h41;  
     @(negedge testbench.reset_tb);      
    
      while(letter_rx < 8'h50)
	begin
	   @(posedge testbench.clk_tb);	 
	    `UART_READ_CHAR(letter_rx);
	    letter_rx <= letter_rx + 8'h01;
	end
      
      #200 testbench.thread_pass <= 1'b1;
     testbench.cpu_pass <= 1'b1;      
      
  end // initial begin
   
   