// Internal chanel buffer design
// 64-bit regesiter with synchronous write port

module Input_ChannelBuffer (
    input clk,
    input reset,
    input [63:0] di; 
    input WE, //write enable signal for the buffer
    output reg [63:0] packet;
    output reg request,  //request for grant
    output reg ToPE; //if the packet is decoded and found with hop value of 0, then ToPE changes to 1;
);
    always @ (posedge clk) begin
        if (reset) 
        packet <= 64'b0;
        else if (WE)
        packet <= di;
    end

    always @ (packet) begin
        if (|packet == 1) 
        request <= 1; // blocking or non-blocking here?
        if (packet[55:48] == 0;)
        ToPE <= 1; //same as above, blcoking or non-blocking?
    end
endmodule