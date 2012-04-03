
task pb_uart_tx;
    input [7:0] tx;
    begin
	$display("PB UART TX 0x%x @ %d", tx, $time);
	
	// wait for the FIFO to not be full
	while (testbench.uart_fifo_status[0])
	  begin
	      repeat (50) @(posedge testbench.clk_tb);
	  end
	
	testbench.uart_tx_data <= tx;
	testbench.uart_tx_write <= 1'b1;
	@(posedge testbench.clk_tb);
	testbench.uart_tx_write <= 1'b0;
    end
endtask // pb_uart_tx

task pb_uart_rx;
    input [7:0] expected;
    begin
	@(posedge testbench.uart_rx_int);
	testbench.uart_rx_read <= 1'b1;
	@(posedge testbench.clk_tb);
	testbench.uart_rx_read <= 1'b0;
	#1 if (testbench.uart_rx_data !== expected)
	  begin
	      $display("FAIL pb_uart_rx: 0x%x expected 0x%x @ %d", testbench.uart_rx_data, expected, $time);
	      testbench.thread_fail <= 1'b1;	     	    
	  end
	else
	  $display("PASS pb_uart_rx: 0x%x @ %d", testbench.uart_rx_data, $time);	
    end
endtask // pb_uart_rx

integer i;

initial
  begin
      `TB.simulation_start;
           
     @(negedge testbench.reset_tb);
     $display("RESET RELEASED @ %d", $time);
     
     //
     // Test 0 -- POR Values
     //
     $display("\n\nTEST 0 -- POR Values %d", $time);
     repeat(3) @(posedge testbench.clk_tb);
     if (testbench.uart_baud_status != 8'h0)
       begin
	  $display("TEST 0 FAIL: UART_BAUD_STATUS  WRONG POR VALUE 0x%x @ %d", testbench.uart_baud_status, $time);
	   `TB.simulation_thread_fail;	   
       end
     
     if (testbench.uart_tx_tb != 1'h1)
       begin
	  $display("TEST 0 FAIL: UART_TX_PAD  WRONG POR VALUE 0x%x @ %d", testbench.uart_tx_tb, $time);
	   `TB.simulation_thread_fail;	   
       end

     if (testbench.uart_tx_int != 1'h0)
       begin
	  $display("TEST 0 FAIL: UART_TX_INT  WRONG POR VALUE 0x%x @ %d", testbench.uart_tx_int, $time);
	   `TB.simulation_thread_fail;	   
       end
     if (testbench.uart_fifo_status != 8'h00)
       begin
	  $display("TEST 0 FAIL: UART_FIFO_STATUS  WRONG POR VALUE 0x%x @ %d", testbench.uart_fifo_status, $time);
	   `TB.simulation_thread_fail;	   
       end
     
     if (testbench.uart_rx_data != 8'h00)
       begin
	  $display("TEST 0 FAIL: UART_RX_DATA  WRONG POR VALUE 0x%x @ %d", testbench.uart_rx_data, $time);
	   `TB.simulation_thread_fail;	   
       end     

     if (testbench.uart_rx_int != 1'h0)
       begin
	  $display("TEST 0 FAIL: UART_RX_INT  WRONG POR VALUE 0x%x @ %d", testbench.uart_rx_int, $time);
	   `TB.simulation_thread_fail;	   
       end

     //
     // Test 1 -- PB UART TX @ 115200 bps
     //
     $display("\n\nTEST 1 -- PB UART TX @ 115200 bps %d", $time);
     repeat(3) @(posedge testbench.clk_tb);
     `UART_CONFIGURE;
      

     repeat(3) @(posedge testbench.clk_tb);
     testbench.uart_baud_count <= 8'h51;
     repeat(3) @(posedge testbench.clk_tb);
     testbench.uart_baud_control <= 8'h80;
     
     repeat(3) @(posedge testbench.clk_tb);
      pb_uart_tx(8'hAA);
      pb_uart_tx(8'hBB);
      pb_uart_tx(8'hCC);
      pb_uart_tx(8'hDD);
      pb_uart_tx(8'hEE);
      pb_uart_tx(8'hFF);
      `UART_READ_CHAR(8'hAA);
      `UART_READ_CHAR(8'hBB);
      `UART_READ_CHAR(8'hCC);
      `UART_READ_CHAR(8'hDD);
      `UART_READ_CHAR(8'hEE);
      `UART_READ_CHAR(8'hFF);
     

     //
     // Test 2 -- PB UART RX @ 115200 bps
     //
     $display("\n\nTEST 2 -- PB UART RX @ 115200 bps %d", $time);
     repeat(3) @(posedge testbench.clk_tb);
      `UART_WRITE_CHAR(8'h55);
      `UART_WRITE_CHAR(8'h66);
      `UART_WRITE_CHAR(8'h77);
      `UART_WRITE_CHAR(8'h88);
      `UART_WRITE_CHAR(8'h99);
      
      pb_uart_rx(8'h55);
      pb_uart_rx(8'h66);
      pb_uart_rx(8'h77);
      pb_uart_rx(8'h88);
      pb_uart_rx(8'h99);

      //
      // Test 3 -- Fill the PB Uart TX Buffer and then some....
      // 
     $display("\n\nTEST 3 -- PB UART TX Fill Buffer %d", $time);
     repeat(3) @(posedge testbench.clk_tb);      
      for (i=0; i<8'h11; i=i+1)
	pb_uart_tx(i);

      $display("Read all data %d", $time);      
      for (i=0; i<8'h10; i=i+1)
	`UART_READ_CHAR(i);
      
     //
     // All Done, Sim Passed!
     //
     repeat(30) @(posedge testbench.clk_tb);
     testbench.thread_pass <= 1'b1;
     
  end // initial begin
        