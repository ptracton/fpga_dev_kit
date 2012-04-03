
`include "timescale.v"

module testbench;
  
    //
    // Free Running 50 MHz clock
    //
    parameter _clk_50mhz_high = 10,
		_clk_50mhz_low  = 10,
		_clk_50mhz_period = _clk_50mhz_high + _clk_50mhz_low;
    
    reg clk_tb;	
    
    initial
      begin
	  clk_tb <= 'b0;
	  forever
	    begin
		#(_clk_50mhz_low)  clk_tb = 1;
		#(_clk_50mhz_high) clk_tb = 0;	     
	    end	
      end
    
    //
    // Global Asynch reset, KEY[3] on the board is ACTIVE LOW
    //
    reg 	     reset_tb; 
    
    initial
      begin
	  reset_tb = 0;
	  #1    reset_tb = 1;
	  #2000 reset_tb = 0;
      end

   
   //
   // UART 
   //
   wire [31:0] uart_adr;
   wire [31:0] uart_dat_o;
   wire [31:0] uart_dat_i;
   wire [3:0]  uart_sel;
   wire        uart_cyc;
   wire        uart_stb;
   wire        uart_we;
   wire        uart_ack;
   wire        uart_int;
   
   wire        uart_tx_tb;
   wire        uart_rx_tb;

   reg 	       reset_tb_uart;

   initial
     begin
	reset_tb_uart = 0;
	#1    reset_tb_uart = 1;
	#1000 reset_tb_uart = 0;
     end
   
   
   assign      uart_dat_o[31:8] = 'b0;

   uart_top uart(
	 	 .wb_clk_i(clk_tb),
		 .wb_rst_i(reset_tb_uart),
		 
		 .wb_adr_i(uart_adr[4:0]),
		 .wb_dat_o(uart_dat_o),
		 .wb_dat_i(uart_dat_i),
		 .wb_sel_i(uart_sel),
		 .wb_cyc_i(uart_cyc),
		 .wb_stb_i(uart_stb),
		 .wb_we_i(uart_we),
		 .wb_ack_o(uart_ack),		 
		 .int_o(uart_int),
		 .stx_pad_o(uart_rx_tb),
		 .srx_pad_i(uart_tx_tb),
		 
		 .rts_pad_o(), 
		 .cts_pad_i(1'b0), 
		 .dtr_pad_o(), 
		 .dsr_pad_i(1'b0), 
		 .ri_pad_i(1'b0), 
		 .dcd_pad_i(1'b0)
		 
		 );
   
   
   wb_mast uart_master( 
			.clk (clk_tb), 
			.rst (reset_tb_uart), 
			.adr (uart_adr), 
			.din (uart_dat_o), 
			.dout(uart_dat_i), 
			.cyc (uart_cyc), 
			.stb (uart_stb), 
			.sel (uart_sel), 
			.we  (uart_we ), 
			.ack (uart_ack), 
			.err (1'b0), 
			.rty (1'b0)
			);   

   
    
    //
    // FPGA to test
    //
   

   /**
    UART Baud
    **/
   reg [7:0]   uart_baud_control;
   reg [7:0]   uart_baud_count;
   wire [7:0]  uart_baud_status;
   
   /**
    UART Transmit
    **/
   reg [7:0]   uart_tx_data;
   wire        uart_tx_int;
   reg 	       uart_tx_write; 
   reg [7:0]   uart_tx_control;
   wire [7:0]  uart_fifo_status;
   /**
    UART Receive
    **/
   wire [7:0]  uart_rx_data;
   wire        uart_rx_int;
   reg 	       uart_rx_read;
      
   initial
     begin
	uart_baud_control <= 8'h00;
	uart_baud_count <= 8'h00;

	uart_tx_data <= 8'h00;
	uart_tx_write <= 1'b0;
	uart_tx_control <= 8'h00;

	uart_rx_read <= 1'b0;	
     end
   
   pb_uart dut(
	       .clk_i(clk_tb),
	       .rst_i(reset_tb),
	       
	       /**
		UART Baud
		**/
	       .uart_baud_control(uart_baud_control),
	       .uart_baud_count(uart_baud_count),
	       .uart_baud_status(uart_baud_status),
	       
	       /**
		UART Transmit
		**/
	       .uart_tx_pad(uart_tx_tb), 
	       .uart_tx_data(uart_tx_data),
	       .uart_tx_int(uart_tx_int),
	       .uart_tx_write(uart_tx_write), 
	       .uart_tx_control(uart_tx_control),
	       .uart_fifo_status(uart_fifo_status),
	       
	       /**
		UART Receive
		**/
	       .uart_rx_pad(uart_rx_tb),
	       .uart_rx_data(uart_rx_data),
	       .uart_rx_int(uart_rx_int),
	       .uart_rx_read(uart_rx_read)
	       );    
   

    
    //
    // Dump signals for waveform viewing
    //
    dump dump();

    //
    // Test bench handling tasks
    //
`include "testbench_tasks.v"
    
   //
   // Tasks to control the UART in the test bench
   //
`include "uart_tasks.v"    
    
    //
    // Include external thread for testing
    //
`include "stimulus.v"
        
endmodule // testbench
