
module dot_product #(parameter WIDTH=16, parameter FRAC=8, parameter LEN=4)(
    input  signed [WIDTH*LEN-1:0] a,
    input  signed [WIDTH*LEN-1:0] b,
    output reg signed [WIDTH-1:0] result
);
    wire signed [WIDTH-1:0] p [0:LEN-1];

    genvar i;
    generate
        for (i=0; i<LEN; i=i+1) begin : MULS
            fp_multiplier #(.WIDTH(WIDTH), .FRAC(FRAC)) mul_i (
                .a(a[WIDTH*i +: WIDTH]),
                .b(b[WIDTH*i +: WIDTH]),
                .result(p[i])
            );
        end
    endgenerate

    integer k;
    reg signed [WIDTH+8:0] acc;

    always @(*) begin
        acc = 0;
        for (k=0; k<LEN; k=k+1)
            acc = acc + p[k];

        if (acc > 32767)
            result = 16'sd32767;
        else if (acc < -32768)
            result = -16'sd32768;
        else
            result = acc[WIDTH-1:0];
    end
endmodule
