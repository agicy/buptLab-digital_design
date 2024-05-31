parameter pill_simulator_frequency = 100000000;
parameter pill_per_second = 5;

module pill_simulator(
    input logic clock,
    input logic reset_n,
    input logic strict_enable,
    input logic pill_disable,
    output logic pill_pulse
);

    logic output_enable;
    assign output_enable = strict_enable || ~ pill_disable;

    logic pill_signal;
    divider #(pill_simulator_frequency / pill_per_second) pill_divider_ins (
        .clock(clock),
        .reset_n(reset_n),
        .clock_out(pill_signal)
    );

    assign pill_pulse = output_enable ? pill_signal : 0;

endmodule
