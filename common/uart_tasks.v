`define UART_CONFIGURE  testbench.uart_configure
`define UART_WRITE_CHAR testbench.uart_write_char
`define UART_READ_CHAR  testbench.uart_read_char

task uart_configure;    
    begin
	
	//Turn on receive data interrupt
	@(posedge testbench.clk_tb);	
	testbench.uart_master.wb_wr1(32'hFFFF0001,    4'h4, 32'h00010000); 
	
	//FIFO Control, interrupt for each byte, clear fifos and enable
	@(posedge testbench.clk_tb);	
	testbench.uart_master.wb_wr1(32'hFFFF0002,    4'h2, 32'h00000700);
	
	//Line Control, enable writting to the baud rate registers
	@(posedge testbench.clk_tb);	
	testbench.uart_master.wb_wr1(32'hFFFF0003,    4'h1, 32'h00000080);
	
	//Baud Rate LSB
	@(posedge testbench.clk_tb);	
	testbench.uart_master.wb_wr1(32'hFFFF0000,    4'h0, 32'h00000051);
	
	//Baud Rate MSB
	@(posedge testbench.clk_tb);	
	testbench.uart_master.wb_wr1(32'hFFFF0001,    4'h4, 32'h00000000);          
	
	//Line Control, 8 bits data, 1 stop bit, no parity
	@(posedge testbench.clk_tb);		
	testbench.uart_master.wb_wr1(32'hFFFF0003,    4'h1, 32'h00000003);  
	
    end
endtask // uart_configure

task uart_write_char;    
    input [7:0] data;
    begin
	$display("UART WRITE CHAR 0x%x %c @%d", data, data, $time);	
	@(posedge testbench.clk_tb);
	testbench.uart_master.wb_wr1(32'hFFFF0000,    4'h0, {24'b0, data});
    end
endtask // uart_write_char


task uart_read_char;    
    input [7:0] expected;
    reg [7:0] 	read_word;    
    begin
	@(posedge testbench.uart_int);
	@(posedge testbench.clk_tb);
	testbench.uart_master.wb_rd1(32'hFFFF0000,    4'h0, read_word);
	if (read_word != expected)
	  begin
	      $display("UART READ CHAR FAIL: Read = 0x%x Expected = 0x%x @ %d", read_word, expected, $time);
	      testbench.thread_fail <= 1'b1;	      
	  end
	else
	  begin
	      $display("UART READ CHAR PASS: Read = 0x%x Expected = 0x%x @ %d", read_word, expected, $time);
	  end
    end
endtask // uart_read_char
     