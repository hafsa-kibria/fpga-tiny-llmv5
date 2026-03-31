
`timescale 1ns/1ps
module tb_task2;

    reg  signed [15:0] ma, mb;
    wire signed [15:0] mres;
    fp_multiplier #(.WIDTH(16), .FRAC(8)) MUL (.a(ma), .b(mb), .result(mres));

    reg  signed [63:0] da, db;
    wire signed [15:0] dres;
    dot_product #(.WIDTH(16), .FRAC(8), .LEN(4)) DOT (.a(da), .b(db), .result(dres));

    reg  signed [63:0] sx_in;
    wire signed [63:0] sx_out;
    softmax_lut #(.WIDTH(16), .FRAC(8), .LEN(4)) SFT (.x_in(sx_in), .x_out(sx_out));

    reg  signed [63:0] lx_in;
    wire signed [63:0] ly_out;
    layer_norm_vec #(.WIDTH(16), .FRAC(8), .DIM(4)) LNM (.x_in(lx_in), .y_out(ly_out));

    initial begin
        $dumpfile("/content/project/waveforms/task2.vcd");
        $dumpvars(0, tb_task2);

        ma = 16'sd256;  mb = 16'sd256;   #10;
        $display("[MUL] 1.0 * 1.0 = %0d (exp 256)", mres);

        ma = 16'sd512;  mb = 16'sd128;   #10;
        $display("[MUL] 2.0 * 0.5 = %0d (exp 256)", mres);

        ma = -16'sd256; mb = 16'sd256;   #10;
        $display("[MUL] -1.0 * 1.0 = %0d (exp -256)", mres);

        ma = 16'sd32767; mb = 16'sd32767; #10;
        $display("[MUL] SAT = %0d (exp 32767)", mres);

        da = {16'sd256,16'sd256,16'sd256,16'sd256};
        db = {16'sd256,16'sd256,16'sd256,16'sd256};
        #10;
        $display("[DOT] [1,1,1,1].[1,1,1,1] = %0d (exp 1024)", dres);

        da = {16'sd512,16'sd128,16'sd256,16'sd0};
        db = {16'sd256,16'sd512,16'sd768,16'sd1024};
        #10;
        $display("[DOT] [2,.5,1,0].[1,2,3,4] = %0d (exp 1536)", dres);

        sx_in = {16'sd256,16'sd256,16'sd256,16'sd256};
        #10;
        $display("[SFT] uniform: %0d %0d %0d %0d (exp ~64 each)",
            sx_out[15:0], sx_out[31:16], sx_out[47:32], sx_out[63:48]);

        sx_in = {16'sd512,16'sd256,16'sd0,-16'sd256};
        #10;
        $display("[SFT] varied:  %0d %0d %0d %0d",
            sx_out[15:0], sx_out[31:16], sx_out[47:32], sx_out[63:48]);

        lx_in = {16'sd1024,16'sd768,16'sd512,16'sd256};
        #10;
        $display("[LNM] vec1: %0d %0d %0d %0d",
            ly_out[15:0], ly_out[31:16], ly_out[47:32], ly_out[63:48]);

        lx_in = {16'sd512,16'sd512,16'sd512,16'sd512};
        #10;
        $display("[LNM] vec2: %0d %0d %0d %0d (exp near 0s)",
            ly_out[15:0], ly_out[31:16], ly_out[47:32], ly_out[63:48]);

        $finish;
    end
endmodule
