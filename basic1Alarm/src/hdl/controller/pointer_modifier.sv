`include "config.svh"

module pointer_modifier #(
    parameter modulus
) (
    input logic clock,
    input logic reset_n,
    input logic add,
    input logic sub,
    output logic [$clog2(modulus)-1:0] pointer
);
    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            pointer <= 'b0;
        end else begin
            if (add && sub) begin
                pointer <= pointer;
            end else if (add) begin
                if (pointer == modulus - 1) begin
                    pointer <= 0;
                end else begin
                    pointer <= pointer + 1;
                end
            end else if (sub) begin
                if (pointer == 0) begin
                    pointer <= modulus - 1;
                end else begin
                    pointer <= pointer - 1;
                end
            end else begin
                pointer <= pointer;
            end
        end
    end
endmodule
