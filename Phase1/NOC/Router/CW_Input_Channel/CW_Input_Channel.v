// This is input channel for Clock Wise, which contains 2 virtual channel (input buffer)
`include "./channelbuffer /Input_ChannelBuffer.v"

module CW_Input_Channel (
    input clk,
    input reset,
    input cwsi,
    input [63:0] cwdi,
    input grant,
    output reg cwri,
    output reg [63:0] dataout
);
    
    reg polarity;
    reg WE_even, WE_odd, request_even, request_odd, ToPE_even, ToPE_odd;
    reg [63:0] packet_even, packet_odd;

    Input_ChannelBuffer VirtualChannel_even (clk, reset, cwdi, WE_even, packet_even, request_even, ToPE_even);

    Input_ChannelBuffer VirtualChannel_odd (clk, reset, cwdi, WE_odd, packet_odd, request_odd, ToPE_odd);

    assign request = request_even | request_odd;
    assign ToPE = ToPE_even | ToPE_odd;

    always @(posedge clk ) begin
      if (reset) begin
        polarity <= 0;
        cwri <= 1;
      end
        else
        polarity <= !polarity;
    end

    always @(posedge clk ) begin
        if (!polarity) begin    //If the before clk's polarity was odd, means now clk's polarity is even, 
                                //so last odd output channel buffer forward data to current router's odd input channel
            if (cwsi) begin
            WE_odd <= 1;
            WE-even <=0;
            end

            if (grant) begin
            dataout <= packet_even;
            cwri <= 1;   //after get grant
            end
            else if (!grant)
            cwri <= 0;
        end 

        if (polarity) begin    //If the before polarity was even, means now clk's polarity is odd, 
                                //so last even output channel buffer forward data to current router's even input channel
            if (cwsi) begin
            WE_even <= 1;
            WE_odd <= 0;
            
            end

          if (grant) begin
            dataout <= packet_odd;
            cwri <= 1;
          end
            else if (!grant)
            cwri <= 0;
        end
    end

    
endmodule