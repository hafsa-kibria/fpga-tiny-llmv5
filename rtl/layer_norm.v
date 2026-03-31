
module layer_norm #(parameter WIDTH=16, parameter FRAC=8)(
    input  clk, rst, valid_in,
    input  signed [WIDTH-1:0] x_in,
    output reg signed [WIDTH-1:0] y_out
);
    always @(posedge clk or posedge rst) begin
        if (rst)          y_out <= 0;
        else if (valid_in) y_out <= x_in;
    end
endmodule
