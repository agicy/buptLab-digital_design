module synchronizer #(
    parameter width
) (
    input logic clock,
    input logic reset_n,
    input logic [width - 1 : 0] in,
    output logic [width - 1 : 0] out
);

    logic [width - 1 : 0] mid;
    always_ff @(posedge clock or negedge reset_n) begin
        if (~ reset_n) begin
            out <= 0;
            mid <= 0;
        end else begin
            out <= mid;
            mid <= in;
        end
    end

endmodule
