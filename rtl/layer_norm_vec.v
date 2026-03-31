
module layer_norm_vec #(parameter WIDTH=16, parameter FRAC=8, parameter DIM=4)(
    input  signed [WIDTH*DIM-1:0] x_in,
    output reg signed [WIDTH*DIM-1:0] y_out
);
    integer i;
    reg signed [WIDTH-1:0] x [0:DIM-1];
    reg signed [WIDTH+8:0] sum;
    reg signed [WIDTH-1:0] mean;

    reg signed [WIDTH-1:0] diff [0:DIM-1];
    reg signed [2*WIDTH-1:0] diff_sq [0:DIM-1];
    reg signed [2*WIDTH+4:0] var_sum;
    reg signed [WIDTH-1:0] var_q;
    reg signed [WIDTH-1:0] inv_std;
    reg signed [2*WIDTH-1:0] mult;

    function signed [WIDTH-1:0] inv_std_approx;
        input signed [WIDTH-1:0] v;
        begin
            if (v <= 16'sd16)        inv_std_approx = 16'sd256;
            else if (v <= 16'sd64)   inv_std_approx = 16'sd181;
            else if (v <= 16'sd128)  inv_std_approx = 16'sd128;
            else if (v <= 16'sd256)  inv_std_approx = 16'sd90;
            else if (v <= 16'sd512)  inv_std_approx = 16'sd64;
            else                     inv_std_approx = 16'sd45;
        end
    endfunction

    always @(*) begin
        for (i=0; i<DIM; i=i+1)
            x[i] = x_in[WIDTH*i +: WIDTH];

        sum = 0;
        for (i=0; i<DIM; i=i+1)
            sum = sum + x[i];
        mean = sum / DIM;

        var_sum = 0;
        for (i=0; i<DIM; i=i+1) begin
            diff[i] = x[i] - mean;
            diff_sq[i] = diff[i] * diff[i];
            var_sum = var_sum + (diff_sq[i] >>> FRAC);
        end

        var_q   = var_sum / DIM;
        inv_std = inv_std_approx(var_q + 16'sd1);

        for (i=0; i<DIM; i=i+1) begin
            mult = diff[i] * inv_std;
            y_out[WIDTH*i +: WIDTH] = mult >>> FRAC;
        end
    end
endmodule
