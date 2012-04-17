
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
		 .stx_pad_o(uart_tx_tb),
		 .srx_pad_i(uart_rx_tb),
		 
		 .rts_pad_o(), 
		 .cts_pad_i(1'b0), 
		 .dtr_pad_o(), 
		 .dsr_pad_i(1'b0), 
		 .ri_pad_i(1'b0), 
		 .dcd_pad_i(1'b0),
		 
		 .baud_o()
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
    // DUT to test
    //
    nexys2 dut(
	       .clk_pad(clk_tb),
	       .rst_pad(reset_tb),
	       
	       .rx_pad(uart_tx_tb),
	       .tx_pad(uart_rx_tb)
	       );    
    
    //
    // Dump signals for waveform viewing
    //
    dump dump();


    //
    // Testbench controlling tasks
    //
`include "testbench_tasks.v"

    initial
      begin
	  `TB.simulation_start;
      end
    
    //
    // Project specific CPU pass/fail detection
    //
    always @(posedge `DUT.register_file.sim_status[6])
      begin
	  $display("CPU PASS @ %d", $time);	  
	  `TB.cpu_pass <= 1;
      end
    
    always @(posedge `DUT.register_file.sim_status[7])
      begin
	  $display("CPU FAIL @ %d", $time);	  
	  `TB.cpu_fail <= 1;
      end

    always @(posedge `DUT.cpu_int_i)
      $display("CPU INT 0x%x @ %d", `DUT.irq_controller.int_src, $time);
    
    
`include "uart_tasks.v"
    
    //
    // Include external thread for testing
    //
`include "stimulus.v"
        
endmodule // testbench
