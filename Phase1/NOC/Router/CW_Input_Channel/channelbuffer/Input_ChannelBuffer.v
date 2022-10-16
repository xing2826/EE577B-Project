// Input chanel buffer design
// 64-bit regesiter with synchronous write port

module Input_ChannelBuffer (
  input clk,
  input reset,
  input [63:0] di, 
  input WE, //write enable signal for the buffer
  input RE,
  output reg [63:0] buffer,
  output reg full
);

  always @ (posedge clk) begin
    if (reset) begin
      buffer <= 64'b0;
      full <= 0;
    end 
    else if (RE) full <= 0;
    else if (WE) begin
      buffer <= di;
      full <= 1;
    end 
  end

endmodule