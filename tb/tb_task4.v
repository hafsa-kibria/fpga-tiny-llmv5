
`timescale 1ns/1ps
module tb_task4;
    reg clk=0, rst=1;
    reg [7:0] token_id;
    reg signed [63:0] wq_all, wk_all, wv_all;
    reg signed [15:0] w_out, w1, w2;
    wire [7:0] token_out;
    wire token_valid, done;
    integer i;
    integer valid_count;
    always #5 clk=~clk;

    model_top #(.WIDTH(16),.FRAC(8),.N_HEADS(4),.DEPTH(32)) uut(
        .clk(clk),.rst(rst),.token_id(token_id),
        .wq_all(wq_all),.wk_all(wk_all),.wv_all(wv_all),
        .w_out(w_out),.w1(w1),.w2(w2),
        .token_out(token_out),
        .token_valid(token_valid),
        .done(done));

    initial begin
        $dumpfile("/content/project/waveforms/task4.vcd");
        $dumpvars(0, tb_task4);

        wq_all = {4{16'd128}};
        wk_all = {4{16'd128}};
        wv_all = {4{16'd128}};
        w_out  = 16'd128;
        w1     = 16'd128;
        w2     = 16'd128;
        valid_count = 0;
        token_id = 0;

        // Long reset
        #200 rst=0;

        // Run until done or timeout
        i = 0;
        while(!done && i < 2000) begin
            token_id = (i/20) % 256;
            @(posedge clk);
            if(token_valid) begin
                $display("[T4] Token%0d: in=%0d out=%0d",
                    valid_count, token_id, token_out);
                valid_count = valid_count + 1;
            end
            i = i + 1;
        end

        #100;
        $display("[T4] Total tokens generated: %0d", valid_count);
        $display("[T4] Done=%0d", done);
        $finish;
    end
endmodule
