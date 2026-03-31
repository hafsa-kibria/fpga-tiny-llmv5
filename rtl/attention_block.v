
module attention_block #(
    parameter WIDTH=16, parameter FRAC=8,
    parameter N_HEADS=4, parameter DEPTH=32
)(
    input  clk, rst,
    input  signed [WIDTH-1:0] x_in,
    input  signed [N_HEADS*WIDTH-1:0] wq_all, wk_all, wv_all,
    input  signed [WIDTH-1:0] w_out,
    output reg signed [WIDTH-1:0] attn_out
);
    reg [$clog2(DEPTH)-1:0] tok_cnt;
    wire [$clog2(DEPTH)-1:0] rd_addr;
    assign rd_addr = (tok_cnt == 0) ? 0 : (tok_cnt - 1);

    wire signed [WIDTH-1:0] q[0:N_HEADS-1];
    wire signed [WIDTH-1:0] k[0:N_HEADS-1];
    wire signed [WIDTH-1:0] v[0:N_HEADS-1];
    wire signed [WIDTH-1:0] k_prev[0:N_HEADS-1];
    wire signed [WIDTH-1:0] v_prev[0:N_HEADS-1];
    wire signed [WIDTH-1:0] scr[0:N_HEADS-1];
    wire signed [WIDTH-1:0] head[0:N_HEADS-1];

    reg  signed [WIDTH+8:0] head_sum;
    wire signed [WIDTH-1:0] head_avg;
    wire signed [WIDTH-1:0] proj_out;

    genvar h;
    generate
        for(h=0;h<N_HEADS;h=h+1) begin : HEADS
            fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) QP(
                .a(x_in),.b(wq_all[h*WIDTH+:WIDTH]),.result(q[h]));
            fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) KP(
                .a(x_in),.b(wk_all[h*WIDTH+:WIDTH]),.result(k[h]));
            fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) VP(
                .a(x_in),.b(wv_all[h*WIDTH+:WIDTH]),.result(v[h]));

            kv_cache #(.WIDTH(WIDTH),.DEPTH(DEPTH)) CACHE(
                .clk(clk),.wr_en(1'b1),
                .wr_addr(tok_cnt),.rd_addr(rd_addr),
                .k_in(k[h]),.v_in(v[h]),
                .k_out(k_prev[h]),.v_out(v_prev[h]));

            fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) SCORE(
                .a(q[h]),.b(k_prev[h]),.result(scr[h]));

            wire signed [WIDTH-1:0] soft_h;
            assign soft_h = (tok_cnt==0) ? 16'sd0 :
                (scr[h]>0 ? ((scr[h]>>>2)>16'sd256 ? 16'sd256 : scr[h]>>>2) : 16'sd64);

            fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) WV(
                .a(soft_h),.b(v_prev[h]),.result(head[h]));
        end
    endgenerate

    integer i;
    always @(*) begin
        head_sum = 0;
        for(i=0;i<N_HEADS;i=i+1) head_sum = head_sum + head[i];
    end
    assign head_avg = head_sum / N_HEADS;

    fp_multiplier #(.WIDTH(WIDTH),.FRAC(FRAC)) OUTPROJ(
        .a(head_avg),.b(w_out),.result(proj_out));

    always @(posedge clk or posedge rst) begin
        if(rst) begin tok_cnt<=0; attn_out<=0; end
        else begin
            attn_out <= proj_out;
            if(tok_cnt < DEPTH-1) tok_cnt <= tok_cnt+1;
        end
    end
endmodule
