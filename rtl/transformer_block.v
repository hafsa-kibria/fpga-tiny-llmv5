
module transformer_block #(
    parameter WIDTH=16, parameter FRAC=8,
    parameter N_HEADS=4, parameter DEPTH=32
)(
    input  clk, rst,
    input  signed [WIDTH-1:0] x_in,
    input  signed [N_HEADS*WIDTH-1:0] wq_all, wk_all, wv_all,
    input  signed [WIDTH-1:0] w_out, w1, w2,
    output signed [WIDTH-1:0] x_out
);
    wire signed [WIDTH-1:0] x_norm1, attn_out, res1, res1_norm, ffn_out;
    reg  signed [WIDTH:0] add1_wide, add2_wide;
    reg  signed [WIDTH-1:0] res1_sat, x_out_sat;

    layer_norm #(.WIDTH(WIDTH),.FRAC(FRAC)) LN1(
        .clk(clk),.rst(rst),.valid_in(1'b1),
        .x_in(x_in),.y_out(x_norm1));

    attention_block #(.WIDTH(WIDTH),.FRAC(FRAC),
        .N_HEADS(N_HEADS),.DEPTH(DEPTH)) ATN(
        .clk(clk),.rst(rst),.x_in(x_norm1),
        .wq_all(wq_all),.wk_all(wk_all),.wv_all(wv_all),
        .w_out(w_out),.attn_out(attn_out));

    always @(*) begin
        add1_wide = x_in + attn_out;
        if      (add1_wide >  32767) res1_sat =  16'sd32767;
        else if (add1_wide < -32768) res1_sat = -16'sd32768;
        else                         res1_sat =  add1_wide[WIDTH-1:0];
    end
    assign res1 = res1_sat;

    layer_norm #(.WIDTH(WIDTH),.FRAC(FRAC)) LN2(
        .clk(clk),.rst(rst),.valid_in(1'b1),
        .x_in(res1),.y_out(res1_norm));

    ffn #(.WIDTH(WIDTH),.FRAC(FRAC)) FFN(
        .x_in(res1_norm),.w1(w1),.w2(w2),.y_out(ffn_out));

    always @(*) begin
        add2_wide = res1 + ffn_out;
        if      (add2_wide >  32767) x_out_sat =  16'sd32767;
        else if (add2_wide < -32768) x_out_sat = -16'sd32768;
        else                         x_out_sat =  add2_wide[WIDTH-1:0];
    end
    assign x_out = x_out_sat;
endmodule
