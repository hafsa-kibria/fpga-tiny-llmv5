
// Argmax FSM: generates MAX_TOK tokens
// Only counts when valid=1 AND token_valid output is high
module argmax_fsm #(
    parameter WIDTH   = 16,
    parameter MAX_TOK = 28
)(
    input  clk, rst,
    input  signed [WIDTH-1:0] logit,
    input  valid,
    output reg [7:0] token_out,
    output reg       token_valid,
    output reg       done
);
    reg [5:0] tok_count;

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            tok_count   <= 0;
            token_out   <= 0;
            token_valid <= 0;
            done        <= 0;
        end else if(valid && !done) begin
            // Only output when logit is valid (not x)
            if(logit !== 16'sbx) begin
                token_out   <= logit[7:0];
                token_valid <= 1;
                tok_count   <= tok_count + 1;
                if(tok_count == MAX_TOK-1) done <= 1;
            end else begin
                token_valid <= 0;
            end
        end else begin
            token_valid <= 0;
        end
    end
endmodule
