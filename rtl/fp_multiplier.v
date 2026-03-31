
module fp_multiplier #(parameter WIDTH=16, parameter FRAC=8)(
    input  signed [WIDTH-1:0] a,
    input  signed [WIDTH-1:0] b,
    output reg signed [WIDTH-1:0] result
);
    reg signed [2*WIDTH-1:0] full;
    reg signed [2*WIDTH-1:0] shifted;

    always @(*) begin
        full    = a * b;
        shifted = full >>> FRAC;

        if (shifted > 32767)
            result = 16'sd32767;
        else if (shifted < -32768)
            result = -16'sd32768;
        else
            result = shifted[WIDTH-1:0];
    end
endmodule
