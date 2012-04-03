
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
    wire [31:0] adr;
    wire [31:0] dat_o;
    wire [31:0] dat_i;
    wire [3:0] 	sel;
    wire        cyc;
    wire 	stb;
    wire 	we;
    wire        ack;
    
    //
    // Master to read/write RAM
    //
   
    
    wb_mast wb_master( 
		       .clk (clk_tb), 
		       .rst (reset_tb), 
		       .adr (adr), 
		       .din (dat_o), 
		       .dout(dat_i), 
		       .cyc (cyc), 
		       .stb (stb), 
		       .sel (sel), 
		       .we  (we ), 
		       .ack (ack), 
		       .err (1'b0), 
		       .rty (1'b0)
			 );       
    //
    // DUT to test
    //
    wb_ram_32x512 dut(
		      .clk_i(clk_tb),
		      .rst_i(reset_tb),
		      
		      .addr_i(adr[10:0]),
		      .data_i(dat_i),
		      .we_i(we),
		      .cyc_i(cyc),
		      .stb_i(stb),
		      .sel_i(sel),
		      
		      .ack_o(ack),
		      .data_o(dat_o)
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
    // Project specific CPU pass/fail detection  -- NO CPU NEEDED
    //
    initial
      begin
	  $display("CPU PASS @ %d", $time);	  
	  `TB.cpu_pass <= 1;
      end      


    task read;
	input  [10:0]	a;
	input [3:0] 	s; 	
	input  [31:0] 	e;	
	output [31:0] 	d;
	begin
	    #3 `TB.wb_master.wb_rd1({21'b0, a}, s, read_word);
	    d = read_word;	
`ifdef ALTERA    
	   if(read_word != e)
`else
	  if(read_word !== e)
`endif
			       
	      begin
		  $display("FAIL: READ ADDR 0x%x DATA 0x%x EXPECTED 0x%x @ %d", a, read_word, e, $time);
		  `TB.thread_fail <= 1'b1;
	      end
	    else
	      $display("READ ADDR 0x%x DATA 0x%x @ %d", a, read_word, $time);	    
	end
    endtask // read

    task write;
	input [10:0]	a;
	input [3:0] 	s;	
	input [31:0] 	d;
	begin
	    $display("WRITE ADDR 0x%x DATA 0x%x @ %d", a,d,$time);	    
	    `TB.wb_master.wb_wr1({21'b0, a}, s, d);	    
	end
	
    endtask // write
    
    
    
    //
    // Include external thread for testing
    //
`include "stimulus.v"
        
endmodule // testbench
