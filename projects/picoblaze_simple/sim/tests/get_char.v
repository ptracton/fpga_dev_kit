  

initial
  begin
      @(negedge testbench.reset_tb);      
      $display("Reset Released @ %d", $time);

      //
      // CPU ss now ready
      //
      @(posedge `DUT.register_file.sim_status[0]);      

      //
      // Configure TB UART
      //
      `UART_CONFIGURE;      
      
      //
      // Send characters 
      //
     @(posedge testbench.clk_tb);
      `UART_WRITE_CHAR(8'hAA);     

     @(posedge testbench.clk_tb);
      `UART_WRITE_CHAR(8'h55);     

     @(posedge testbench.clk_tb);
      `UART_WRITE_CHAR(8'hC0);     

     @(posedge testbench.clk_tb);
      `UART_WRITE_CHAR(8'h33);
      
     @(posedge testbench.clk_tb);
      `UART_WRITE_CHAR(8'h61);     
     
      testbench.thread_pass <='b1;
  end // initial begin
   
