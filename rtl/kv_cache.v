
module kv_cache #(parameter WIDTH=16, parameter DEPTH=32)(
    input  clk, wr_en,
    input  [$clog2(DEPTH)-1:0] wr_addr, rd_addr,
    input  signed [WIDTH-1:0] k_in, v_in,
    output signed [WIDTH-1:0] k_out, v_out
);
    reg signed [WIDTH-1:0] k_mem [0:DEPTH-1];
    reg signed [WIDTH-1:0] v_mem [0:DEPTH-1];
    integer i;
    initial begin
        for(i=0;i<DEPTH;i=i+1) begin k_mem[i]=0; v_mem[i]=0; end
    end
    always @(posedge clk) begin
        if(wr_en) begin
            k_mem[wr_addr] <= k_in;
            v_mem[wr_addr] <= v_in;
        end
    end
    assign k_out = k_mem[rd_addr];
    assign v_out = v_mem[rd_addr];
endmodule
