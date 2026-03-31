
module ffn #(parameter WIDTH=16, parameter FRAC=8)(
    input  signed [WIDTH-1:0] x_in, w1, w2,
    output signed [WIDTH-1:0] y_out
);
    wire signed [WIDTH-1:0] h, act;
    fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) L1(.a(x_in),.b(w1),.result(h));
    assign act = h[WIDTH-1] ? 16'sd0 : h;
    fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) L2(.a(act),.b(w2),.result(y_out));
endmodule
