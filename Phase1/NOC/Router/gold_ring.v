//the module shown in ''2022fall_cardinal_router.pdf' figure 3 
//containing 4 RTR and 2 PER modules.
parameter state_even = 2'b01;
parameter state_odd = 2'b10;
parameter state_idle = 2'b00;

module input_control(
  input clk,
  input reset,
	input si,
  input [63:0] di,
  input [1:0]state,
  input flag_req_vc1,
  input flag_req_vc2,
  input flag_2p_vc1,
  input flag_2p_vc2,
  output reg ri,
  output reg vc_req_1,
  output reg vc_req_2,
  output reg vc_2p_1,
  output reg vc_2p_2,
  output reg [63:0] vc_up_1,
  output reg [63:0] vc_up_2
  );
  
  reg [63:0] vc_1;
  reg [63:0] vc_2;

  reg vc_r1;
  reg vc_r2;
  
  always @(posedge clk) begin
    if(reset) begin
     	vc_r1 <= 1;
      vc_r2 <= 1;
      vc_req_1 <= 0;
      vc_req_2 <= 0;
      vc_2p_1 <= 0;
      vc_2p_2 <= 0;
    end
  end
  
  
  always @(*) begin
    if(flag_req_vc1 == 1 || flag_2p_vc1 == 1) vc_r1 = 1;
    if(flag_req_vc2 == 1 || flag_2p_vc2 == 1) vc_r2 = 1;

    case(state)

      state_odd: begin 
        ri = vc_r1;
        if(si == 1) begin
        	vc_1 = di;
          vc_r1 = 1'b0;
          ri = 1'b0;
        end
      end

      state_even: begin
        ri = vc_r2;
        if(si == 1) begin
          vc_2 = di;
          vc_r2 = 1'b0;
			    ri = 1'b0;
        end
      end

      default: ri = 1;

    endcase
  end
  
  always @(*) begin
    if(flag_req_vc1 == 1) begin
      vc_req_1 = 0;
      vc_1 = 64'd0;
    end
    if(flag_req_vc2 == 1) begin
      vc_req_2 = 0;
      vc_2 = 64'd0;
    end
    if(flag_2p_vc1 == 1) begin
      vc_2p_1 = 0;
      vc_1 = 64'd0;
    end
    if(flag_2p_vc2 == 1) begin
      vc_2p_2 = 0;
      vc_2 = 64'd0;
    end

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
      end
      else begin
        vc_up_2 = {vc_2[63:56], 1'b0, vc_2[55:49], vc_2[47:0]};
        vc_req_2 = 1'b1;
      end
    end
  end
endmodule

module input_control_processor(
  input clk,
  input reset,
	input si,
  input [63:0] di,
  input [1:0]state,
  input flag_req_cw_vc1,
  input flag_req_cw_vc2,
  input flag_req_ccw_vc1,
  input flag_req_ccw_vc2,
  output reg ri,
  output reg vc_req_cw_1,
  output reg vc_req_cw_2,
  output reg vc_req_ccw_1,
  output reg vc_req_ccw_2,
  output reg [63:0] vc_up_1,
  output reg [63:0] vc_up_2
  );
  
  
  reg [63:0] vc_1;
  reg [63:0] vc_2;

  reg vc_r1;
  reg vc_r2;
  
  always @(posedge clk) begin
    if(reset) begin
     	vc_r1 <= 1;
      vc_r2 <= 1;
      vc_req_cw_1 <= 0;
      vc_req_cw_2 <= 0;
      vc_req_ccw_1 <= 0;
      vc_req_ccw_2 <= 0;
    end
  end
  
  always @(*) begin
    if(flag_req_cw_vc1 == 1 || flag_req_ccw_vc1 == 1) begin 
      vc_r1 = 1;
      vc_1 = 64'd0;
      if(flag_req_cw_vc1 == 1) vc_req_cw_1 = 0;
      else vc_req_ccw_1 = 0;
    end
    if(flag_req_cw_vc2 == 1 || flag_req_ccw_vc2 == 1) begin
      vc_r2 = 1;
      vc_2 = 64'd0;
      if(flag_req_cw_vc2 == 1) vc_req_cw_2 = 0;
      else vc_req_ccw_2 = 0;      
    end

    case(state)
      state_odd: begin 
        ri = vc_r1;
        if(si == 1) begin
        	vc_1 = di;
          vc_up_1 = {vc_1[63:56], 1'b0, vc_1[55:49], vc_1[47:0]};
          vc_r1 = 1'b0;
          ri = 1'b0;
          if(vc_1[62] == 0) vc_req_cw_1 = 1;
          else vc_req_ccw_1 = 1;
        end
      end
      
      state_even: begin
        ri = vc_r2;
        if(si == 1) begin
          vc_2 = di;
          vc_up_2 = {vc_2[63:56], 1'b0, vc_2[55:49], vc_2[47:0]};
          vc_r2 = 1'b0;
          ri = 1'b0;
          if(vc_2[62] == 0) vc_req_cw_2 = 1;
          else vc_req_ccw_2 = 1;
        end
      end
      
      default: ri = 1;
    endcase
  end 
endmodule

module arbiter(
  input [1:0]state,
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
        state_even:begin
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

        state_odd:begin
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

        default: begin
          dout <= 0;
          dout_valid <= 0;
        end
      endcase
    end
  end
endmodule

module router(
  input clk,
  input reset,
  output reg polarity,
  
	input cwsi,
  input [63:0] cwdi,
	output cwri,
  
  input ccwsi,
  input [63:0] ccwdi,
  output ccwri,

  input pesi,
  input [63:0] pedi,
  output peri,

  input cwro,
  output cwso,
  output [63:0] cwdo,

  input ccwro,
  output ccwso,
  output [63:0] ccwdo,

  input pero,
  output peso,
  output [63:0] pedo
  );

  
  /*-------state translation and output generation----*/
  reg [1:0] state, next_state;
  
  always @(posedge clk) begin
    if(reset) begin
        state <= state_idle;
      	polarity <= 0;
    end
 	  else state <= next_state;
  end
  
  always @(*) begin
    case(state)
      state_even: next_state = state_odd;
      state_odd: next_state = state_even;
      default: next_state = state_even;
    endcase
  end
  
  always @(*) begin
    case(state)
      state_odd: polarity = 1'b0;
      state_even: polarity = 1'b1;
      default: polarity = 1'b0;
    endcase
  end 

  /*-------cw input control------*/
  wire cw_flag_req_vc1;
  wire cw_flag_req_vc2;
  wire cw_flag_2p_vc1;
  wire cw_flag_2p_vc2;
  wire cw_2p_vc1;
  wire cw_2p_vc2;
  wire cw_vc_req_1;
  wire cw_vc_req_2;
  wire cw_vc_2p_1;
  wire cw_vc_2p_2;
  wire [63:0] cw_vc_up_1;
  wire [63:0] cw_vc_up_2;
  
  input_control cw(
    .clk(clk),
    .reset(reset),
    .si(cwsi),
    .di(cwdi),
    .state(state),
    .flag_req_vc1(cw_flag_req_vc1),
    .flag_req_vc2(cw_flag_req_vc2),
    .flag_2p_vc1(cw_flag_2p_vc1),
    .flag_2p_vc2(cw_flag_2p_vc2),
    .ri(cwri),
    .vc_req_1(cw_vc_req_1),
    .vc_req_2(cw_vc_req_2),
    .vc_2p_1(cw_vc_2p_1),
    .vc_2p_2(cw_vc_2p_2),
    .vc_up_1(cw_vc_up_1),
    .vc_up_2(cw_vc_up_2)
    );

  /*----ccw input control----*/
	wire ccw_flag_req_vc1;
  wire ccw_flag_req_vc2;
  wire ccw_flag_2p_vc1;
  wire ccw_flag_2p_vc2;
  wire ccw_2p_vc1;
  wire ccw_2p_vc2;
  wire ccw_vc_req_1;
  wire ccw_vc_req_2;
  wire ccw_vc_2p_1;
  wire ccw_vc_2p_2;
  wire [63:0] ccw_vc_up_1;
  wire [63:0] ccw_vc_up_2;
    
  input_control ccw(
    .clk(clk),
    .reset(reset),
    .si(ccwsi),
    .di(ccwdi),
    .state(state),
    .flag_req_vc1(ccw_flag_req_vc1),
    .flag_req_vc2(ccw_flag_req_vc2),
    .flag_2p_vc1(ccw_flag_2p_vc1),
    .flag_2p_vc2(ccw_flag_2p_vc2),
    .ri(ccwri),
    .vc_req_1(ccw_vc_req_1),
    .vc_req_2(ccw_vc_req_2),
    .vc_2p_1(ccw_vc_2p_1),
    .vc_2p_2(ccw_vc_2p_2),
    .vc_up_1(ccw_vc_up_1),
    .vc_up_2(ccw_vc_up_2));
    
 /*------processor input control----*/
  wire p_flag_req_cw_vc1;
  wire p_flag_req_cw_vc2;
  wire p_flag_req_ccw_vc1;
  wire p_flag_req_ccw_vc2;
  wire p_vc_req_cw_1;
  wire p_vc_req_cw_2;
  wire p_vc_req_ccw_1;
  wire p_vc_req_ccw_2;
  wire [63:0] p_vc_up_1;
  wire [63:0] p_vc_up_2;

  input_control_processor processor(
    .clk(clk),
    .reset(reset),
    .si(pesi),
    .di(pedi),
    .state(state),
    .flag_req_cw_vc1(p_flag_req_cw_vc1),
    .flag_req_cw_vc2(p_flag_req_cw_vc2),
    .flag_req_ccw_vc1(p_flag_req_ccw_vc1),
    .flag_req_ccw_vc2(p_flag_req_ccw_vc2),
    .ri(peri),
    .vc_req_cw_1(p_vc_req_cw_1),
    .vc_req_cw_2(p_vc_req_cw_2),
    .vc_req_ccw_1(p_vc_req_ccw_1),
    .vc_req_ccw_2(p_vc_req_ccw_2),
    .vc_up_1(p_vc_up_1),
    .vc_up_2(p_vc_up_2));

  /*------------cw arbiter--------------*/
  wire [63:0]cw_dout;
  wire cw_dout_valid;
    
  arbiter cw_arbiter(
    .clk(clk),
    .reset(reset),
    .state(state),
    .vc_1_req1(p_vc_req_cw_1),
    .vc_1_req2(cw_vc_req_1), 
    .vc_2_req1(p_vc_req_cw_2), 
    .vc_2_req2(cw_vc_req_2), 
    .vc_1_req_buffer_1(p_vc_up_1), 
    .vc_1_req_buffer_2(cw_vc_up_1), 
    .vc_2_req_buffer_1(p_vc_up_2), 
    .vc_2_req_buffer_2(cw_vc_up_2), 
    .dout(cw_dout), 
    .dout_valid(cw_dout_valid), 
    .flag_vc1_req1(p_flag_req_cw_vc1), 
    .flag_vc1_req2(cw_flag_req_vc1), 
    .flag_vc2_req1(p_flag_req_cw_vc2), 
    .flag_vc2_req2(cw_flag_req_vc2));
  
    assign cwso = (cwro && cw_dout_valid) ? 1 : 0;
    assign cwdo = cw_dout;
    
  /*------------ccw arbiter--------------*/
  wire [63:0]ccw_dout;
  wire ccw_dout_valid;
    
  arbiter ccw_arbiter(
    .clk(clk),
    .reset(reset),
    .state(state),
    .vc_1_req1(p_vc_req_ccw_1),
    .vc_1_req2(ccw_vc_req_1), 
    .vc_2_req1(p_vc_req_ccw_2), 
    .vc_2_req2(ccw_vc_req_2), 
    .vc_1_req_buffer_1(p_vc_up_1), 
    .vc_1_req_buffer_2(ccw_vc_up_1), 
    .vc_2_req_buffer_1(p_vc_up_2), 
    .vc_2_req_buffer_2(ccw_vc_up_2), 
    .dout(ccw_dout), 
    .dout_valid(ccw_dout_valid), 
    .flag_vc1_req1(p_flag_req_ccw_vc1), 
    .flag_vc1_req2(ccw_flag_req_vc1), 
    .flag_vc2_req1(p_flag_req_ccw_vc2), 
    .flag_vc2_req2(ccw_flag_req_vc2));
    
    assign ccwso = (ccwro && ccw_dout_valid) ? 1 : 0;
    assign ccwdo = ccw_dout;
    
  /*-----------processor arbiter--------*/
  wire [63:0]pe_dout;
  wire pe_dout_valid;
    
  arbiter processor_arbiter(
    .clk(clk),
    .reset(reset),
    .state(state),
    .vc_1_req1(cw_vc_2p_1),
    .vc_1_req2(ccw_vc_2p_1), 
    .vc_2_req1(cw_vc_2p_2), 
    .vc_2_req2(ccw_vc_2p_2), 
    .vc_1_req_buffer_1(cw_vc_up_1), 
    .vc_1_req_buffer_2(ccw_vc_up_1), 
    .vc_2_req_buffer_1(cw_vc_up_2), 
    .vc_2_req_buffer_2(ccw_vc_up_2), 
    .dout(pe_dout), 
    .dout_valid(pe_dout_valid), 
    .flag_vc1_req1(cw_flag_2p_vc1), 
    .flag_vc1_req2(ccw_flag_2p_vc1), 
    .flag_vc2_req1(cw_flag_2p_vc2), 
    .flag_vc2_req2(ccw_flag_2p_vc2));
  
    assign peso = (pero && pe_dout_valid) ? 1 : 0;
    assign pedo = pe_dout;

endmodule
    
module ring (
    input clk,
    input reset,

    input net_so1,
    input [63:0] net_do1,
    input net_ri1,
    output net_si1,
    output net_ro1,
    output net_ploarity1,
    output [63:0] net_di1,

    input net_so2,
    input [63:0] net_do2,
    input net_ri2,
    output net_si2,
    output net_ro2,
    output net_ploarity2,
    output [63:0] net_di2,

    input net_so3,
    input [63:0] net_do3,
    input net_ri3,
    output net_si3,
    output net_ro3,
    output net_ploarity3,
    output [63:0] net_di3,

    input net_so4,
    input [63:0] net_do4,
    input net_ri4,
    output net_si4,
    output net_ro4,
    output net_ploarity4,
    output [63:0] net_di4, 
  );

    wire cwso4_cwsi1, cwso1_cwsi2, cwso2_cwsi3, cwso3_cwsi4;
    wire cwri1_cwro4, cwri4_cwro3, cwri3_cwro2, cwri2_cwro1;
    
    wire ccwso4_ccwsi1, ccwso1_ccwsi2, ccwso2_ccwsi3, ccwso3_ccwsi4;
    wire ccwri1_ccwro4, ccwri4_ccwro3, ccwri3_ccwro2, ccwri2_ccwro1;

    wire [63:0] cwdo4_cwdi1, cwdo1_cwdi2, cwdo2_cwdi3, cwdo3_cwdi4;
    wire [63:0] ccwdo4_ccwdi1, ccwdo1_ccwdi2, ccwdo2_ccwdi3, ccwdo3_ccwdi4;
    

  router node1 (
    .clk(clk),
    .reset(reset),
    .polarity(net_ploarity1),
  
	  .cwsi(cwso4_cwsi1),
    .cwdi(cwdo4_cwdi1),
	  .cwri(cwri1_cwro4),
  
    .ccwsi(ccwso4_ccwsi1),
    .ccwdi(ccwdo4_ccwdi1),
	  .ccwri(ccwri1_ccwro4),
  
  	.pesi(net_so1),
  	.pedi(net_do1),
	  .peri(net_ro1),
  
  	.cwro(cwri2_cwro1),
  	.cwso(cwso1_cwsi2),
  	.cwdo(cwdo1_cwdi2),
  
  	.ccwro(ccwri2_ccwro1),
  	.ccwso(ccwso1_ccwsi2),
  	.ccwdo(ccwdo1_ccwdi2),
  
  	.pero(net_ri1),
  	.peso(net_si1),
  	.pedo(net_di1)
    );

  router node2 (
    .clk(clk),
   	.reset(reset),
  	.polarity(net_ploarity2),
  
	  .cwsi(cwso1_cwsi2),
  	.cwdi(cwdo1_cwdi2),
	  .cwri(cwri2_cwro1),
  
  	.ccwsi(ccwso1_ccwsi2),
  	.ccwdi(ccwdo1_ccwdi2),
	  .ccwri(ccwri2_ccwro1),
  
  	.pesi(net_so2),
  	.pedi(net_do2),
	  .peri(net_ro2),
  
  	.cwro(cwri3_cwro2),
  	.cwso(cwso2_cwsi3),
  	.cwdo(cwdo2_cwdi3),
  
  	.ccwro(ccwri3_ccwro2),
  	.ccwso(ccwso2_ccwsi3),
  	.ccwdo(ccwdo2_ccwdi3),
  
  	.pero(net_ri2),
  	.peso(net_si2),
  	.pedo(net_di2)
    );

  router node3 (
    .clk(clk),
   	.reset(reset),
  	.polarity(net_ploarity3),
  
	  .cwsi(cwso2_cwsi3),
  	.cwdi(cwdo2_cwdi3),
	  .cwri(cwri3_cwro2),
  
  	.ccwsi(ccwso2_ccwsi3),
  	.ccwdi(ccwdo2_ccwdi3),
	  .ccwri(ccwri3_ccwro2),
  
  	.pesi(net_so3),
  	.pedi(net_do3),
	  .peri(net_ro3),
  
  	.cwro(cwri4_cwro3),
  	.cwso(cwso3_cwsi4),
  	.cwdo(cwdo3_cwdi4),
  
  	.ccwro(ccwri4_ccwro3),
  	.ccwso(ccwso4_ccwsi3),
  	.ccwdo(ccwdo3_ccwdi4),
  
  	.pero(net_ri3),
  	.peso(net_si3),
  	.pedo(net_di3)
    );

  router node4 (
    .clk(clk),
   	.reset(reset),
  	.polarity(net_ploarity4),
  
	  .cwsi(cwso3_cwsi4),
  	.cwdi(cwdo3_cwdi4),
	  .cwri(cwri4_cwro3),
  
  	.ccwsi(ccwso3_ccwsi4),
  	.ccwdi(ccwdo3_ccwdi4),
	  .ccwri(ccwri4_ccwro3),
  
  	.pesi(net_so4),
  	.pedi(net_do4),
	  .peri(net_ro4),
  
  	.cwro(cwri1_cwro4),
  	.cwso(cwso4_cwsi1),
  	.cwdo(cwdo4_cwdi1),
  
  	.ccwro(ccwri1_ccwro4),
  	.ccwso(ccwso4_ccwsi1),
  	.ccwdo(ccwdo4_ccwdi1),
  
  	.pero(net_ri4),
  	.peso(net_si4),
  	.pedo(net_di4)
    );

endmodule
    
    