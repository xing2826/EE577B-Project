module router(
  	input clk,
   	input reset,
  
	input cwsi,
  	input [63:0] cwdi,
	output cwri,
  
  	input ccwsi,
  	input [63:0] ccwdi,
  	output ccwri,
  
);
  //state translation and output generation
  parameter state_even = 1'b1;
  parameter state_odd = 1'b0;
  
  reg state;
  
  always @(posedge clk) begin
    if(reset) begin
        state <= state_odd;
    end
 	else state <= ~state;
  end
  
  always @(*) begin
    case(state)
      state_odd: polarity = 1'b0;
      state_even: polarity = 1'b1;
    endcase
    
// cw input control
    wire cw_flag_vc1;
    wire cw_flag_vc2;
    wire cw_vc_req_1;
    wire cw_vc_req_2;
    wire cw_vc_2p_1;
    wire cw_vc_2p_1;
    wire cw_vc_up_1;
    wire cw_vc_up_2;
    
    input_control cw(
    	.clk(clk),
    	.reset(reset),
      	.si(cwsi),
      	.di(cwdi),
    	.state(state),
      	.flag_vc1(cw_flag_vc1),
      	.flag_vc2(cw_flag_vc2),
      	.ri(cwri),
      	.vc_req_1(cw_vc_req_1),
      	.vc_req_2(cw_vc_req_2),
      	.vc_2p_1(cw_vc_2p_1),
      	.vc_2p_2(cw_vc_2p_2),
      	.vc_up_1(cw_vc_up_1),
      	.vc_up_2(cw_vc_up_2));
    
    wire ccw_flag_vc1;
    wire ccw_flag_vc2;
    wire ccw_vc_req_1;
    wire ccw_vc_req_2;
    wire ccw_vc_2p_1;
    wire ccw_vc_2p_1;
    wire ccw_vc_up_1;
    wire ccw_vc_up_2;
    
    input_control ccw(
    	.clk(clk),
    	.reset(reset),
      	.si(ccwsi),
      	.di(ccwdi),
    	.state(state),
      	.flag_vc1(ccw_flag_vc1),
      	.flag_vc2(ccw_flag_vc2),
      	.ri(ccwri),
      	.vc_req_1(ccw_vc_req_1),
      	.vc_req_2(ccw_vc_req_2),
      	.vc_2p_1(ccw_vc_2p_1),
      	.vc_2p_2(ccw_vc_2p_2),
      	.vc_up_1(ccw_vc_up_1),
      	.vc_up_2(ccw_vc_up_2));
    
  
  
endmodule


    
    
    module arbiter(
      input state;
      input clk,
      input reset,
      input vc_1_req1,
      input vc_1_req2,
      input vc_2_req1,
      input vc_2_req2,
      input [63:0] vc_1_req_buffer_1,
      input [63:0] vc_1_req_buffer_2,
      input [63:0] vc_2_req_buffer_1,
      input [63:0] vc_2_req_buffer_2,
      output reg [63:0] dout,
);
      
      reg [1:0] vc_1_valiable_priority;
      reg [1:0] vc_2_valiable_priority;

      wire [1:0] vc_1_grant;
      wire [1:0] vc_2_grant;

      wire [1:0] vc_1_req = {vc_1_req2, vc_1_req1};
      wire [3:0] vc_1_double_req = {vc_1_req, vc_1_req};
      wire [3;0] vc_1_double_grant;
      assign vc_1_double_grant = vc_1_double_req &(~(vc_1_double_req - vc_1_valiable_priority));
      assign vc_1_grant = vc_1_double_grant[3:2] & vc_1_double_grant[1:0];
      
      wire [1:0] vc_2_req = {vc_2_req2, vc_2_req1};
      wire [3:0] vc_2_double_req = {vc_2_req, vc_2_req};
      wire [3;0] vc_2_double_grant;
      assign vc_2_double_grant = vc_2_double_req &(~(vc_2_double_req - vc_2_valiable_priority));
      assign vc_2_grant = vc_2_double_grant[3:2] & vc_2_double_grant[1:0];
      
      always @(posedge clk) begin
        if(reset) begin
          vc_1_valiable_priority <= 2'b01;
          vc_2_valiable_priority <= 2'b01;
        end
        else begin
          case(state)
            state_odd:begin
              vc_1_valiable_priority = {vc_1_grant[0], vc_1_grant[1]}
              if(vc_1_grant == 1'b1) dout <= vc_1_req_buffer_1;
              else dout <= vc_1_req_buffer_2;
            end
            state_even:begin
              vc_2_valiable_priority = {vc_2_grant[0], vc_2_grant[1]}
              if(vc_2_grant == 1'b1) dout <= vc_2_req_buffer_1;
              else dout <= vc_2_req_buffer_2;
            end
        end
      end
    endmodule