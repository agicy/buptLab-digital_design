module counter #(
    parameter modulus
) (
    input logic clock,
    input logic reset_n,
    input logic enable,
    output logic [$clog2(modulus)-1:0] count,
    output logic carry
);
    always_ff @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            count <= 0;
            carry <= 0;
        end else if (enable) begin
            if (count >= modulus - 1) begin
                count <= 0;
                carry <= 1;
            end else begin
                count <= count + 1;
                carry <= 0;
            end
        end
    end
endmodule
