
`timescale 1ns/1ps
module tb_task3;
    reg clk=0, rst=1;
    always #5 clk=~clk;

    reg  kv_wr_en;
    reg  [4:0] kv_wr_addr, kv_rd_addr;
    reg  signed [15:0] kv_k_in, kv_v_in;
    wire signed [15:0] kv_k_out, kv_v_out;

    kv_cache #(.WIDTH(16),.DEPTH(32)) KVC(
        .clk(clk),.wr_en(kv_wr_en),
        .wr_addr(kv_wr_addr),.rd_addr(kv_rd_addr),
        .k_in(kv_k_in),.v_in(kv_v_in),
        .k_out(kv_k_out),.v_out(kv_v_out));

    reg  signed [15:0] ffn_x, ffn_w1, ffn_w2;
    wire signed [15:0] ffn_y;
    ffn #(.WIDTH(16),.FRAC(8)) FFN_UUT(
        .x_in(ffn_x),.w1(ffn_w1),.w2(ffn_w2),.y_out(ffn_y));

    reg  signed [15:0] ax_in;
    reg  signed [63:0] awq_all, awk_all, awv_all;
    reg  signed [15:0] aw_out;
    wire signed [15:0] attn_y;
    attention_block #(.WIDTH(16),.FRAC(8),.N_HEADS(4),.DEPTH(32)) ATTN_UUT(
        .clk(clk),.rst(rst),.x_in(ax_in),
        .wq_all(awq_all),.wk_all(awk_all),.wv_all(awv_all),
        .w_out(aw_out),.attn_out(attn_y));

    reg  signed [15:0] tx_in;
    reg  signed [63:0] twq_all, twk_all, twv_all;
    reg  signed [15:0] tw_out, tw1, tw2;
    wire signed [15:0] tx_out;
    transformer_block #(.WIDTH(16),.FRAC(8),.N_HEADS(4),.DEPTH(32)) TR_UUT(
        .clk(clk),.rst(rst),.x_in(tx_in),
        .wq_all(twq_all),.wk_all(twk_all),.wv_all(twv_all),
        .w_out(tw_out),.w1(tw1),.w2(tw2),.x_out(tx_out));

    integer err;
    task check_close;
        input [127:0] label;
        input integer got, exp, tol;
        begin
            err = got - exp;
            if(err < 0) err = -err;
            $display("[T3] %s got=%0d exp=%0d err=%0d %s",
                label, got, exp, err, (err<=tol) ? "PASS" : "FAIL");
        end
    endtask

    initial begin
        $dumpfile("/content/project/waveforms/task3.vcd");
        $dumpvars(0, tb_task3);

        kv_wr_en=0; kv_wr_addr=0; kv_rd_addr=0; kv_k_in=0; kv_v_in=0;
        ffn_x=0; ffn_w1=0; ffn_w2=0;
        ax_in=0; awq_all=0; awk_all=0; awv_all=0; aw_out=0;
        tx_in=0; twq_all=0; twk_all=0; twv_all=0; tw_out=0; tw1=0; tw2=0;

        #20 rst=1; #20 rst=0;

        // KV-cache test
        kv_wr_en=1; kv_wr_addr=5; kv_rd_addr=5;
        kv_k_in=16'sd123; kv_v_in=16'sd77;
        #10; kv_wr_en=0; #2;
        check_close("KV_cache_k", kv_k_out, 123, 0);
        check_close("KV_cache_v", kv_v_out, 77,  0);

        // FFN test
        ffn_x=16'sd256; ffn_w1=16'sd128; ffn_w2=16'sd128;
        #10;
        check_close("FFN_single", ffn_y, 64, 0);

        // Attention tests
        rst=1; #10; rst=0;
        ax_in=16'sd256;
        awq_all={16'sd128,16'sd128,16'sd128,16'sd128};
        awk_all={16'sd128,16'sd128,16'sd128,16'sd128};
        awv_all={16'sd128,16'sd128,16'sd128,16'sd128};
        aw_out=16'sd128;
        #12;
        check_close("ATTN_tok1", attn_y, 0, 0);
        ax_in=16'sd512; #12;
        check_close("ATTN_tok2", attn_y, 8, 30);

        // Transformer block tests
        rst=1; #10; rst=0;
        tx_in=16'sd256;
        twq_all={16'sd128,16'sd128,16'sd128,16'sd128};
        twk_all={16'sd128,16'sd128,16'sd128,16'sd128};
        twv_all={16'sd128,16'sd128,16'sd128,16'sd128};
        tw_out=16'sd128; tw1=16'sd128; tw2=16'sd128;
        #24;
        check_close("TR_tok1", tx_out, 320, 2);
        tx_in=16'sd512; #24;
        check_close("TR_tok2", tx_out, 650, 3);

        rst=1; #10; rst=0;
        tx_in=-16'sd256;
        twq_all={16'sd128,16'sd128,16'sd128,16'sd128};
        twk_all={16'sd128,16'sd128,16'sd128,16'sd128};
        twv_all={16'sd128,16'sd128,16'sd128,16'sd128};
        tw_out=16'sd128; tw1=16'sd128; tw2=16'sd128;
        #24;
        check_close("TR_neg_tok", tx_out, -256, 5);

        $finish;
    end
endmodule
