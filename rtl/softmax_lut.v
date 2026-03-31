
module softmax_lut #(parameter WIDTH=16, parameter FRAC=8, parameter LEN=4)(
    input  signed [WIDTH*LEN-1:0] x_in,
    output reg signed [WIDTH*LEN-1:0] x_out
);
    integer i;
    reg signed [WIDTH-1:0] x [0:LEN-1];
    reg signed [WIDTH-1:0] xmax;
    reg signed [WIDTH-1:0] s [0:LEN-1];
    reg signed [WIDTH-1:0] e [0:LEN-1];
    reg signed [WIDTH+8:0] esum;
    reg signed [WIDTH-1:0] tmp;

    function signed [WIDTH-1:0] exp_approx;
        input signed [WIDTH-1:0] v;
        begin
            if (v >= 0)               exp_approx = 16'sd256;
            else if (v >= -16'sd64)   exp_approx = 16'sd200;
            else if (v >= -16'sd128)  exp_approx = 16'sd155;
            else if (v >= -16'sd192)  exp_approx = 16'sd121;
            else if (v >= -16'sd256)  exp_approx = 16'sd94;
            else if (v >= -16'sd384)  exp_approx = 16'sd57;
            else if (v >= -16'sd512)  exp_approx = 16'sd35;
            else                      exp_approx = 16'sd8;
        end
    endfunction

    always @(*) begin
        for (i=0; i<LEN; i=i+1)
            x[i] = x_in[WIDTH*i +: WIDTH];

        xmax = x[0];
        for (i=1; i<LEN; i=i+1)
            if (x[i] > xmax) xmax = x[i];

        esum = 0;
        for (i=0; i<LEN; i=i+1) begin
            s[i] = x[i] - xmax;
            e[i] = exp_approx(s[i]);
            esum = esum + e[i];
        end

        for (i=0; i<LEN; i=i+1) begin
            tmp = (e[i] <<< FRAC) / esum;
            x_out[WIDTH*i +: WIDTH] = tmp;
        end
    end
endmodule
