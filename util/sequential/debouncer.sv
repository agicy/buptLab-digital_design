module debouncer #(
    parameter frequency,
    modulus
) (
    input  logic clock,
    input  logic reset_n,
    input  logic in,
    output logic out
);
    logic last_in;
    logic [$clog2(modulus)-1:0] count;
    always_ff @(posedge clock or negedge reset_n)
        if (~reset_n) begin
            count <= 0;
            last_in <= 0;
            out <= 0;
        end else
            if (in != last_in) begin
                last_in <= in;
                count <= modulus - 1;
            end else
                if (count)
                    count <= count - 1;
                else
                    out <= last_in;
endmodule
