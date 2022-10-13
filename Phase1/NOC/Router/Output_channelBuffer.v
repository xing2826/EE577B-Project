// Internal chanel buffer design
// 64-bit regesiter with synchronous write  port


module Output_ChannelBuffer (
    input clk,
    input reset,
    input [63:0] di,
    input WE,
    output reg [63:0] packet;
    output reg request;
);
    
endmodule