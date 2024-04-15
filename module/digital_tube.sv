parameter digital_tube_frequency = 100000000;
parameter least_frequency = 100;
parameter tube_number = 8;
parameter segment_number = 7;
parameter data_width = 6;

module digital_tube (
    input logic clock,
    input logic reset_n,
    input logic [tube_number - 1 : 0][data_width - 1 : 0] data_code,
    input logic [tube_number - 1 : 0] data_dp,
    output logic [tube_number - 1 : 0] enable_n,
    output logic [segment_number - 1 : 0] segment_n,
    output logic dp_n
);

    logic clock_digital_tube;
    divider #(digital_tube_frequency / (tube_number * least_frequency)) dtb_divider (
        .clock(clock),
        .reset_n(reset_n),
        .clock_out(clock_digital_tube)
    );

    logic [$clog2(tube_number) - 1 : 0] display_select;
    always_ff @(posedge clock_digital_tube or negedge reset_n)
        if (~ reset_n)
            display_select <= 0;
        else
            if (display_select == tube_number - 1)
                display_select <= 0;
            else
                display_select <= display_select + 1;

    logic [data_width - 1 : 0] display_code;
    logic display_dp;

    assign display_code = data_code[display_select];
    assign display_dp = data_dp[display_select];

    logic [segment_number - 1 : 0] display_segment_n;
    segment_decoder sd_ins (
        .data(display_code),
        .segment_n(display_segment_n)
    );

    always_comb
        for (int i = 0; i < tube_number; i++)
            enable_n[i] = (display_select != i);

    assign segment_n = display_segment_n;
    assign dp_n = ~ display_dp;

endmodule
