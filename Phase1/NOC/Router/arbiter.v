module arbiter(
      input state,
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
      output reg dout_valid,  //flag used to indicate if dout is a valid data
      output reg flag_vc1_req1,
      output reg flag_vc1_req2,
      output reg flag_vc2_req1,
      output reg flag_vc2_req2

);	
  	 parameter state_even = 1'b1;
 	 parameter state_odd = 1'b0;
      
      reg [1:0] vc_1_valiable_priority;
      reg [1:0] vc_2_valiable_priority;

      wire [1:0] vc_1_grant;
      wire [1:0] vc_2_grant;

      wire [1:0] vc_1_req = {vc_1_req2, vc_1_req1};
      wire [3:0] vc_1_double_req = {vc_1_req, vc_1_req};
  wire [3:0] vc_1_double_grant;
      assign vc_1_double_grant = vc_1_double_req &(~(vc_1_double_req - vc_1_valiable_priority));
  assign vc_1_grant = vc_1_double_grant[3:2] | vc_1_double_grant[1:0];
      
      wire [1:0] vc_2_req = {vc_2_req2, vc_2_req1};
      wire [3:0] vc_2_double_req = {vc_2_req, vc_2_req};
  wire [3:0] vc_2_double_grant;
      assign vc_2_double_grant = vc_2_double_req &(~(vc_2_double_req - vc_2_valiable_priority));
  assign vc_2_grant = vc_2_double_grant[3:2] | vc_2_double_grant[1:0];
      
      always @(posedge clk) begin
        if(reset) begin
          vc_1_valiable_priority <= 2'b01;
          vc_2_valiable_priority <= 2'b01;
        end
        else begin
            flag_vc1_req1 <= 0;
            flag_vc1_req2 <= 0;
            flag_vc2_req1 <= 0;
            flag_vc2_req2 <= 0;
        
          case(state)
            state_odd:begin
              if (|vc_1_req) begin
                dout_valid <= 1;
                vc_1_valiable_priority <= {vc_1_grant[0], vc_1_grant[1]};
              end
              else dout_valid <= 0;
              if(vc_1_grant == 2'b01) begin
                dout <= vc_1_req_buffer_1;
                flag_vc1_req1 <= 1;  //if request from CW/CCW in VC1 is granted, send flage to cancel the request
              end
                else flag_vc1_req1<= 0;

            if (vc_1_grant == 2'b10)begin
                dout <= vc_1_req_buffer_2;
                flag_vc1_req2 <= 1;   //if request from PE in VC1 is grantted, send flag to cancel the request
            end
                else flag_vc1_req2 <= 0;

            if (vc_1_grant == 2'b00)begin
                flag_vc1_req1 <= 0;
                flag_vc1_req2 <= 0;
            end
            
            end
            state_even:begin
              if (|vc_2_req) begin
                dout_valid <= 1;
                vc_2_valiable_priority <= {vc_2_grant[0], vc_2_grant[1]};
              end
              else dout_valid <= 0;
              if(vc_2_grant == 2'b01) begin
                dout <= vc_2_req_buffer_1;
                flag_vc2_req1 <= 1;  //if request from CW/CCW in VC1 is granted, send flage to cancel the request
              end
                else flag_vc2_req1<= 0;

            if (vc_2_grant == 2'b10)begin
                dout <= vc_2_req_buffer_2;
                flag_vc2_req2 <= 1;   //if request from PE in VC1 is grantted, send flag to cancel the request
            end
                else flag_vc2_req2 <= 0;

            if (vc_2_grant == 2'b00)begin
                flag_vc2_req1 <= 0;
                flag_vc2_req2 <= 0;
            end
            

            end
          endcase
        end
      end
    endmodule