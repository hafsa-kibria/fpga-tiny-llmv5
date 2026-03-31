
module model_top #(
    parameter WIDTH   = 16,
    parameter FRAC    = 8,
    parameter N_HEADS = 4,
    parameter DEPTH   = 32
)(
    input  clk, rst,
    input  [7:0] token_id,
    input  signed [N_HEADS*WIDTH-1:0] wq_all, wk_all, wv_all,
    input  signed [WIDTH-1:0]         w_out, w1, w2,
    output [7:0] token_out,
    output       token_valid,
    output       done
);
    wire signed [WIDTH-1:0] embed;
    wire signed [WIDTH-1:0] L0_out, L1_out, L2_out, L3_out;

    embedding #(.WIDTH(WIDTH)) EMB(
        .clk(clk),.token_id(token_id),.embed_out(embed));

    transformer_block #(.WIDTH(WIDTH),.FRAC(FRAC),
        .N_HEADS(N_HEADS),.DEPTH(DEPTH)) B0(
        .clk(clk),.rst(rst),.x_in(embed),
        .wq_all(wq_all),.wk_all(wk_all),.wv_all(wv_all),
        .w_out(w_out),.w1(w1),.w2(w2),.x_out(L0_out));

    transformer_block #(.WIDTH(WIDTH),.FRAC(FRAC),
        .N_HEADS(N_HEADS),.DEPTH(DEPTH)) B1(
        .clk(clk),.rst(rst),.x_in(L0_out),
        .wq_all(wq_all),.wk_all(wk_all),.wv_all(wv_all),
        .w_out(w_out),.w1(w1),.w2(w2),.x_out(L1_out));

    transformer_block #(.WIDTH(WIDTH),.FRAC(FRAC),
        .N_HEADS(N_HEADS),.DEPTH(DEPTH)) B2(
        .clk(clk),.rst(rst),.x_in(L1_out),
        .wq_all(wq_all),.wk_all(wk_all),.wv_all(wv_all),
        .w_out(w_out),.w1(w1),.w2(w2),.x_out(L2_out));

    transformer_block #(.WIDTH(WIDTH),.FRAC(FRAC),
        .N_HEADS(N_HEADS),.DEPTH(DEPTH)) B3(
        .clk(clk),.rst(rst),.x_in(L2_out),
        .wq_all(wq_all),.wk_all(wk_all),.wv_all(wv_all),
        .w_out(w_out),.w1(w1),.w2(w2),.x_out(L3_out));

    argmax_fsm #(.WIDTH(WIDTH),.MAX_TOK(28)) FSM(
        .clk(clk),.rst(rst),
        .logit(L3_out),.valid(1'b1),
        .token_out(token_out),
        .token_valid(token_valid),
        .done(done));
endmodule
