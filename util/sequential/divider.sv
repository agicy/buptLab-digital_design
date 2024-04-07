module divider #(parameter divisor) (
    input logic clock,
    input logic reset_n,
    output logic clock_out
);

    logic[$clog2(divisor)-1:0] cntValue;
    assign cntValue = divisor - 1;

    logic[$clog2(divisor)-1:0] count_pos;
    always_ff @(posedge clock or negedge reset_n) begin
        if (~ reset_n) begin
            count_pos <= 0;
        end else begin
            if (count_pos >= cntValue) begin
                count_pos <= 0;
            end else begin
                count_pos <= count_pos + 1;
            end
        end
    end

    logic clock_pos;
    always_ff @(posedge clock or negedge reset_n) begin
        if (~ reset_n) begin
            clock_pos <= 0;
        end else if ((count_pos == (cntValue >> 1)) || (count_pos == cntValue)) begin
            clock_pos <= ~ clock_pos;
        end
    end

    generate
        if (divisor % 2 == 1) begin: odd_divisor
            logic[$clog2(divisor)-1:0] count_neg;
            always_ff @(negedge clock or negedge reset_n) begin
                if (~ reset_n) begin
                    count_neg <= 0;
                end else begin
                    if (count_neg >= cntValue) begin
                        count_neg <= 0;
                    end else begin
                        count_neg <= count_neg + 1;
                    end
                end
            end

            logic clock_neg;
            always_ff @(negedge clock or negedge reset_n) begin
                if (~ reset_n) begin
                    clock_neg <= 0;
                end else if ((count_neg == (cntValue >> 1)) || (count_neg == cntValue)) begin
                    clock_neg <= ~ clock_neg;
                end
            end
            assign clock_out = clock_pos | clock_neg;
        end else begin: even_divisor
            assign clock_out = clock_pos;
        end
    endgenerate

endmodule
