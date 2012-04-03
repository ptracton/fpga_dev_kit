


module dump;
   
   initial
     begin
`ifdef NCVERILOG
	$shm_open("test.shm");
	$shm_probe(testbench, "ASM");
`else	
	$dumpfile("dump.vcd");
	$dumpvars(0, testbench);
`endif
	
     end // initial begin
   
   
endmodule // test_top