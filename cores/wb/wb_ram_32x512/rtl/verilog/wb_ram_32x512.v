//                              -*- Mode: Verilog -*-
// Filename        : wb_ram_32x512.v
// Description     : WB RAM 32x512
// Author          : Phil Tracton
// Created On      : Sun Mar 25 21:12:43 2012
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!


module wb_ram_32x512(
		     input wire clk_i,
		     input wire rst_i,

		     input wire [10:0] addr_i,
		     input wire [31:0] data_i,
		     input wire we_i,
		     input wire cyc_i,
		     input wire stb_i,
		     input wire [3:0] sel_i,
		     
		     output reg ack_o,
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
    wire [31:0] 			wr_data;
    
    assign wr_data[31:24] = sel_i[3] ? data_i[31:24] : data_o[31:24];
    assign wr_data[23:16] = sel_i[2] ? data_i[23:16] : data_o[23:16];
    assign wr_data[15: 8] = sel_i[1] ? data_i[15: 8] : data_o[15: 8];
    assign wr_data[ 7: 0] = sel_i[0] ? data_i[ 7: 0] : data_o[ 7: 0];
    
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
	 if (sel_i != 4'b1111) 
	   ack_o <= 1'b0;
    
    
    //
    // Xilinx RAMB memories
    //
`ifdef XILINX
    initial $display("XILINX WB 32x512 RAM");
    wire  enable = |( sel_i & {4{cyc_i & stb_i}}); 
 

    RAMB16_S36  RAMB16_S36_inst (
				 .DO(data_o), // 32-bit Data Output
				 .DOP( ), // 4-bit parity Output
				 .ADDR(address), // 9-bit Address Input
				 .CLK(clk_i), // Clock
				 .DI(wr_data), // 32-bit Data Input
				 .DIP(4'b0), // 4-bit parity Input
				 .EN(enable), // RAM Enable Input
				 .SSR(rst_i), // Synchronous Set/Reset Input
				 .WE(we_i) // Write Enable Input
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
				      .data_a (wr_data[7:0]),
				      .wren_a (we_i),
				      .q_a (data_o[7:0]),
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

    wire [31:0] mem40 = memory[9'h040];
    wire [31:0] mem44 = memory[9'h044];
    
 `endif // !`ifdef ALTERA
`endif // !`ifdef XILINX
       
    
endmodule // ram

