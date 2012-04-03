//                              -*- Mode: Verilog -*-
// Filename        : wb_ram_8x2k.v
// Description     : Wishbone RAM 8x2K
// Author          : Phil Tracton
// Created On      : Sat Mar 24 21:55:46 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

module wb_ram_8x2k(
		   input wire clk_i,
		   input wire rst_i,
		   
		   input wire [10:0] addr_i,
		   input wire [7:0] data_i,
		   input wire we_i,
		   input wire cyc_i,
		   input wire stb_i,
		   input wire sel_i,
		   
		   output reg ack_o,
		   output wire [7:0] data_o
		   );

   
    //
    // Write data to the SRAMS, use a mux to select which bank gets the new
    // data and which ones hold their data
    //
    wire [7:0] 	      wr_data;
    assign wr_data[7:0] = sel_i ? data_i[ 7: 0] : data_o[ 7: 0];

    //
    // Acknowledge memory cycle so the master knows it is finished
    //
    always @ (posedge clk_i)
      if (rst_i)
	ack_o <= 1'b0;
     else
       if (!ack_o) 
	 begin
	     if (cyc_i & stb_i)
	       ack_o <= 1'b1; 
	 end  
       else
	 if (sel_i != 1'b1) 
	   ack_o <= 1'b0;


    //
    // Xilinx RAMB memories
    //
`ifdef XILINX
    initial $display("XILINX WB RAM 8x2K RAM");
    wire  enable = sel_i & cyc_i & stb_i; 
 
    RAMB16_S9 ram0(
		   .DO(data_o[7:0]), 
		   .DOP(), 
		   .ADDR(addr_i), 
		   .CLK(clk_i),
		   .DI(wr_data[7:0]), 
		   .DIP(1'b0), 
		   .EN(enable), 
		   .SSR(rst_i), 
		   .WE(we_i)
		   );  
`else 

    //
    // ALTERA syncram memories
    //
 `ifdef ALTERA
    initial
      begin
	  $display("ALTERA WB RAM 8x2K RAM");
      end

    altsyncram	altsyncram_component (
				      .aclr0 (rst_i),
				      .address_a (addr_i),
				      .clock0 (clk_i),
				      .data_a (wr_data[7:0]),
				      .wren_a (we_i),
				      .q_a (data_o[7:0]),
				      .aclr1 (1'b0),
				      .address_b (1'b1),
				      .addressstall_a (1'b0),
				      .addressstall_b (1'b0),
				      .byteena_a (1'b1),
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
      altsyncram_component.numwords_a = 2048,
      altsyncram_component.operation_mode = "SINGLE_PORT",
      altsyncram_component.widthad_a = 11,
      altsyncram_component.width_a = 8,
      altsyncram_component.width_byteena_a = 1;    
    
 `else

   initial $display("ASIC WB RAM 8x2K RAM");
    //
    // Generic "ASIC" based memory.  Real ASICs would need a model from the vendor!
    // 
    reg [7:0] memory[0:2047];
    assign data_o = memory[addr_i];    
    wire [7:0] mem0 = memory[0];
    wire [7:0] mem1 = memory[1];
    wire [7:0] mem2 = memory[2];
    wire [7:0] mem3 = memory[3];
    
    
    
    always @(posedge clk_i)
      if (we_i & cyc_i & stb_i)
	memory[addr_i] <= wr_data;    
	
 `endif // !`ifdef ALTERA
`endif // !`ifdef XILINX
           
endmodule // wb_ram_8x2k
