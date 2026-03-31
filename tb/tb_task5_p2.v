`timescale 1ns/1ps
module tb_task5_p2;
    reg clk = 0, rst = 1;
    reg  [7:0]  token_id;
    reg  signed [63:0]  wq_all, wk_all, wv_all;
    reg  signed [15:0]  w_out, w1, w2;
    wire signed [15:0]  x_out;
    wire [7:0]  token_out;
    wire        token_valid, done;

    always #5 clk = ~clk;

    wire signed [15:0] embed_w;
    assign embed_w = {8'b0, token_id};

    transformer_block #(.WIDTH(16),.FRAC(8),.N_HEADS(4),.DEPTH(32)) B0(
        .clk(clk),.rst(rst),.x_in(embed_w),
        .wq_all(wq_all),.wk_all(wk_all),.wv_all(wv_all),
        .w_out(w_out),.w1(w1),.w2(w2),.x_out(x_out));

    initial begin
        $dumpfile("/content/project/waveforms/task5_p2.vcd");
        $dumpvars(0, tb_task5_p2);

        wq_all = {16'sd128, 16'sd128, 16'sd128, 16'sd128};
        wk_all = {16'sd128, 16'sd128, 16'sd128, 16'sd128};
        wv_all = {16'sd128, 16'sd128, 16'sd128, 16'sd128};
        w_out  = 16'sd128;
        w1     = 16'sd128;
        w2     = 16'sd128;
        token_id = 0;

        #30 rst = 0;
        #20;

        token_id = 8'd8; #100;
        $display("[P2T1] tok=%0d out=%0d", token_id, x_out);
        token_id = 8'd7; #100;
        $display("[P2T2] tok=%0d out=%0d", token_id, x_out);
        token_id = 8'd6; #100;
        $display("[P2T3] tok=%0d out=%0d", token_id, x_out);
        token_id = 8'd5; #100;
        $display("[P2T4] tok=%0d out=%0d", token_id, x_out);
        token_id = 8'd4; #100;
        $display("[P2T5] tok=%0d out=%0d", token_id, x_out);
        token_id = 8'd3; #100;
        $display("[P2T6] tok=%0d out=%0d", token_id, x_out);
        token_id = 8'd2; #100;
        $display("[P2T7] tok=%0d out=%0d", token_id, x_out);
        token_id = 8'd1; #100;
        $display("[P2T8] tok=%0d out=%0d", token_id, x_out);

        $display("[P2] DONE");
        $finish;
    end
endmodule
