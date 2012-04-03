
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
    assign dat_o[31:8] = 'b0;    
    wb_ram_8x2k dut(
		    .clk_i(clk_tb),
		    .rst_i(reset_tb),
		    
		    .addr_i(adr[10:0]),
		    .data_i(dat_i[7:0]),
		    .we_i(we),
		    .cyc_i(cyc),
		    .stb_i(stb),
		    .sel_i(sel[0]),
		    
		    .ack_o(ack),
		    .data_o(dat_o[7:0])
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
	input  [7:0] 	e;	
	output [7:0] 	d;
	begin
	    `TB.wb_master.wb_rd1({21'b0, a}, 1'b1, read_word);
	    d = read_word[7:0];	    
	    #3 if(read_word[7:0] !== e)
	      begin
		  $display("FAIL: READ ADDR 0x%x DATA 0x%x EXPECTED 0x%x @ %d", a, read_word[7:0], e, $time);
		  `TB.thread_fail <= 1'b1;
	      end
	    else
	      $display("READ ADDR 0x%x DATA 0x%x @ %d", a, read_word[7:0], $time);	    
	end
    endtask // read

    task write;
	input [10:0]	a;
	input [7:0] 	d;
	begin
	    $display("WRITE ADDR 0x%x DATA 0x%x @ %d", a,d,$time);	    
	    `TB.wb_master.wb_wr1({21'b0, a}, 1'b1, {24'b0, d});	    
	end
	
    endtask // write
    
    
    
    //
    // Include external thread for testing
    //
`include "stimulus.v"
        
endmodule // testbench
