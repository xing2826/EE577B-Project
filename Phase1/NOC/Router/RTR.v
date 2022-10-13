// input channel design
// track the ploarity to do the virtual channel multiplexing: 
// e.g. even polarity: internally... externally... ; odd polarity: internally... externally...
// Moore machine state machine design for handshake signal
// contain 2 set of channel buffers for each input channel, sharing the same control logic and physic channel

module RTR (
    input clk,
    input reset,
    input si,
    input ri,
    input [63:0] di,
    output so,
    output ro,
    output reg [63:0] do;
);
    always @ (posedge clk) begin
        if (reset) begin
            do <= 64'b0;

        end

        else begin                  
            if (si & ri) do <= di;   //at the rising clock, reg the input value into buffer

        end
    end
endmodule