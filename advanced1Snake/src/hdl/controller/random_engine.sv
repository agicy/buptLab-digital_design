module random_engine #(
    parameter width = 32
) (
    input logic clock,
    input logic reset_n,
    output logic [width-1:0] random_number
);

    logic [width-1:0] lfsr;
    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            lfsr <= 32'h12345678;
        end else begin
            lfsr <= {lfsr[width-2:0], lfsr[width-1] ^ lfsr[width-2]};
        end
    end

    assign random_number = lfsr;

endmodule
