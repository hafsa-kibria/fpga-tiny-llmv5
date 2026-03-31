
module embedding #(parameter WIDTH=16, parameter VOCAB=256)(
    input  clk,
    input  [7:0] token_id,
    output reg signed [WIDTH-1:0] embed_out
);
    always @(posedge clk)
        embed_out <= {8'b0, token_id};
endmodule
