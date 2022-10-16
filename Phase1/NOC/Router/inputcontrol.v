module input_control(
   input clk,
   input reset,
   input si,
   input [63:0] di,
   input state,
   output reg ri,
   output reg vc_req_1,
   output reg vc_req_2,
   output reg vc_2p_1,
   output reg vc_2p_2,
   output reg [63:0] vc_up_1,
   output reg [63:0] vc_up_2
    );
  
  parameter state_even = 1'b1;
  parameter state_odd = 1'b0;
  
  reg [63:0] vc_1;
  reg [63:0] vc_2;

  reg vc_r1;
  reg vc_r2;
  
  always @(posedge clk) begin
    if(reset) begin
      vc_r1 <= 1;
       vc_r2 <= 1;
    end
  end
  
  always @(*) begin
    case(state)
      state_odd: begin 
        ri = vc_r1;
        if(si == 1) begin
         vc_1 = di;
           vc_r1 = 1'b0;
           
        end
      end
      state_even: begin
        ri = vc_r2;
        if(si == 1) begin
           vc_2 = di;
           vc_r2 = 1'b0;
        end
      end
    endcase
  end
  
  always @(*) begin
    if(|vc_1)begin
      if(vc_1[55:48] == 8'd0) begin
        vc_2p_1 = 1'b1;
       vc_up_1 = vc_1;
      end
      else begin
        vc_up_1 = {vc_1[63:56], 1'b0, vc_1[55:49], vc_1[47:0]};
        vc_req_1 = 1'b1;
      end
    end
    if(|vc_2)begin
      if(vc_2[55:48] == 8'd0) begin
        vc_2p_2 = 1'b1;
        vc_up_2 = vc_2;
      else begin
        vc_up_2 = {vc_2[63:56], 1'b0, vc_2[55:49], vc_2[47:0]};
        vc_req_2 = 1'b1;
      end
    end
  end
endmodule

module router()
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
      reg [3;0] vc_1_double_grant;
      assign vc_1_double_grant = vc_1_double_req &(~(vc_1_double_req - vc_1_valiable_priority));
      assign vc_1_grant = vc_1_double_grant[3:2] & vc_1_double_grant[1:0];
      
      wire [1:0] vc_2_req = {vc_2_req2, vc_2_req1};
      wire [3:0] vc_2_double_req = {vc_2_req, vc_2_req};
      reg [3;0] vc_2_double_grant;
      assign vc_2_double_grant = vc_2_double_req &(~(vc_2_double_req - vc_2_valiable_priority));
      assign vc_2_grant = vc_2_double_grant[3:2] & vc_2_double_grant[1:0];
      
      always @(posedge clk) begin
        if(reset) begin
          vc_1_valiable_priority <= 2'b0001;
          vc_2_valiable_priority <= 2'b0001;
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