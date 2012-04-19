
reg [7:0] letter;


initial
  begin
      testbench.thread_fail <= 1'b0;
      letter <= 8'h41;
      
      @(negedge testbench.reset_tb);
      $display("Reset Released @ %d", $time);
      `UART_CONFIGURE;
      while(letter <= 8'h45)
	begin
	    #3 $display("Waiting for 0x%h @ %d", letter, $time);	    
	    `UART_READ_CHAR(letter);
	    letter <= letter + 8'h01;
	end

      
      #20 testbench.thread_pass <= 1'b1;      
      
  end
    