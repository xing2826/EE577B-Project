

module tb;
  reg state, clk, reset, vc_1_req1, vc_1_req2, vc_2_req1, vc_2_req2;
  reg [63:0] vc_1_req_buffer_1, vc_1_req_buffer_2, vc_2_req_buffer_1, vc_2_req_buffer_2;
  wire [63:0] dout;
  wire dout_valid, flag_vc1_req1, flag_vc1_req2, flag_vc2_req1, flag_vc2_req2;
  

  always #2 clk =!clk;  //runing in 250MHz
  always #4 state = !state; 

  arbiter tb (state, clk, reset, vc_1_req1, vc_1_req2, vc_2_req1, vc_2_req2, vc_1_req_buffer_1, 
  vc_1_req_buffer_2, vc_2_req_buffer_1, vc_2_req_buffer_2, dout, dout_valid, flag_vc1_req1, flag_vc1_req2, flag_vc2_req1, flag_vc2_req2);

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;

    //$monitor("at time:%gns, money is %b, price is %b", $time, money, price, );
    
    clk = 0; state = 0; reset = 1;  
    #4;
    reset = 0; 
    vc_1_req1 = 1;
    vc_1_req2 = 1;
    vc_2_req1 = 1;
    vc_2_req2 = 1;
    vc_1_req_buffer_1 = 64'h1fffffff00000000;
    vc_1_req_buffer_2 = 64'h17ffffff00000000;
    vc_2_req_buffer_1 = 64'h13ffffff00000000;
    vc_2_req_buffer_2 = 64'h11ffffff00000000;
    #16;
    vc_1_req1 = 1;
    vc_1_req2 = 0;
    vc_2_req1 = 1;
    vc_2_req2 = 1;
    #16

flag_req_vc1
    

    

    $finish;
  end
endmodule