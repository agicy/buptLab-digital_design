module timing #(
    parameter timing_count
) (
    input  logic clock,
    input  logic reset_n,
    output logic clock_out[0 : timing_count - 1]
);

    logic [$clog2(timing_count) - 1 : 0] count;
    always_ff @(posedge clock or negedge reset_n) begin
        if (~ reset_n)
            count <= 0;
        else
            if (count >= timing_count - 1)
                count <= 0;
            else
                count <= count + 1;
    end

    always_comb
        for (int i = 0; i < timing_count; i++)
            clock_out[i] <= (count == i);

endmodule
