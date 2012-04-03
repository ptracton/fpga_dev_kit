//                              -*- Mode: Verilog -*-
// Filename        : wb_ram_32x512.v
// Description     : WB RAM 32x512
// Author          : Phil Tracton
// Created On      : Sun Mar 25 21:12:43 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

`include "timescale.v"
module wb_ram_32x512(
		     input wire clk_i,
		     input wire rst_i,

		     input wire [10:0] addr_i,
		     input wire [31:0] data_i,
		     input wire we_i,
		     input wire cyc_i,
		     input wire stb_i,
		     input wire [3:0] sel_i,
		     
		     output wire ack_o,
		     output wire [31:0] data_o
		     );
    
    
    //
    // Shift the address over by 2 bits to word align the data
    //
    wire [10:0] 			address = addr_i >> 2;
 
    //
    // Write data to the SRAMS, use a mux to select which bank gets the new
    // data and which ones hold their data
    //
   wire [31:0] 				wr_data;
   
   assign 				wr_data[31:24] = sel_i[3] ? data_i[31:24] : data_o[31:24];
   assign 				wr_data[23:16] = sel_i[2] ? data_i[23:16] : data_o[23:16];
   assign 				wr_data[15: 8] = sel_i[1] ? data_i[15: 8] : data_o[15: 8];
   assign 				wr_data[ 7: 0] = sel_i[0] ? data_i[ 7: 0] : data_o[ 7: 0];
  
   //
   // Acknowledge memory cycle so the master knows it is finished
   //
   reg 					ack_we;
   reg 					ack_re;   
   assign 				ack_o = ack_re | ack_we;
   
   // 
   // Write acknowledge 
   // 
   always @ (negedge clk_i) 
     if (rst_i) 
       ack_we <= 1'b0; 
     else 
       if (cyc_i & stb_i & we_i & ~ack_we) 
	 ack_we <= #1 1'b1; 
       else 
	 ack_we <= #1 1'b0; 
   
   // 
   // read acknowledge 
   // 
   always @ (posedge clk_i) 
	if (rst_i) 
	  ack_re <= 1'b0; 
	else 
	  if (cyc_i & stb_i & ~we_i & ~ack_re) 
	    ack_re <= #1 1'b1; 
	  else 
	    ack_re <= #1 1'b0; 
   
    
    
   //
    // Xilinx RAMB memories
    //
`ifdef XILINX
    initial $display("XILINX WB 32x512 RAM");

   wire [3:0] 				enable = 4'hF;   
   wire [3:0] 				we = sel_i & {4{cyc_i & stb_i & we_i}};

   
    RAMB16_S9 ram0(
		   .DO(data_o[7:0]), 
		   .DOP(), 
		   .ADDR({3'b0,address}), 
		   .CLK(clk_i),
		   .DI(wr_data[7:0]), 
		   .DIP(1'b0), 
		   .EN(enable[0]), 
		   .SSR(rst_i), 
		   .WE(we[0])
		   );

    RAMB16_S9 ram1(
		   .DO(data_o[15:8]), 
		   .DOP(), 
		   .ADDR({3'b0,address}), 
		   .CLK(clk_i),
		   .DI(wr_data[15:8]), 
		   .DIP(1'b0), 
		   .EN(enable[1]), 
		   .SSR(rst_i), 
		   .WE(we[1])
		   );

    RAMB16_S9 ram2(
		   .DO(data_o[23:16]), 
		   .DOP(), 
		   .ADDR({3'b0,address}), 
		   .CLK(clk_i),
		   .DI(wr_data[23:16]), 
		   .DIP(1'b0), 
		   .EN(enable[2]), 
		   .SSR(rst_i), 
		   .WE(we[2])
		   );

    RAMB16_S9 ram3(
		   .DO(data_o[31:24]), 
		   .DOP(), 
		   .ADDR({3'b0,address}), 
		   .CLK(clk_i),
		   .DI(wr_data[31:24]), 
		   .DIP(1'b0), 
		   .EN(enable[3]), 
		   .SSR(rst_i), 
		   .WE(we[3])
		   );
`else 

    //
    // ALTERA syncram memories
    //
 `ifdef ALTERA
    initial $display("ALTERA WB 32x512 RAM");

    altsyncram	altsyncram_component (
				      .aclr0 (rst_i),
				      .address_a (addr_i),
				      .clock0 (clk_i),
				      .data_a (wr_data),
				      .wren_a (we_i),
				      .q_a (data_o),
				      .aclr1 (1'b0),
				      .address_b (1'b1),
				      .addressstall_a (1'b0),
				      .addressstall_b (1'b0),
				      .byteena_a (sel_i),
				      .byteena_b (1'b1),
				      .clock1 (1'b1),
				      .clocken0 (1'b1),
				      .clocken1 (1'b1),
				      .clocken2 (1'b1),
				      .clocken3 (1'b1),
				      .data_b (1'b1),
				      .eccstatus (),
				      .q_b (),
				      .rden_a (1'b1),
				      .rden_b (1'b1),
				      .wren_b (1'b0));
    defparam
      altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
      altsyncram_component.lpm_type = "altsyncram",
      altsyncram_component.numwords_a = 512,
      altsyncram_component.operation_mode = "SINGLE_PORT",
      altsyncram_component.widthad_a = 9,
      altsyncram_component.width_a = 32,
      altsyncram_component.width_byteena_a = 4;  
    
 `else

   initial $display("ASIC WB 32x512 RAM");
    //
    // Generic "ASIC" based memory.  Real ASICs would need a model from the vendor!
    // 
    reg [31:0] memory[0:511];

    
    assign data_o = memory[address];
    always @(posedge clk_i)
      if (we_i & cyc_i & stb_i)
	memory[address] <= wr_data;    
    
 `endif // !`ifdef ALTERA
`endif // !`ifdef XILINX
       
    
endmodule // ram

