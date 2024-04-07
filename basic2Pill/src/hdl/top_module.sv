`include "config.svh"


module top_module (
    input logic clock,
    input logic reset,
    input logic strict_enable,
    input logic [4:0] raw_button,
    input logic [3:0] keyboard_row_n,
    output logic [3:0] keyboard_col_n,
    output logic [7:0] digital_tube_enable_n,
    output logic [6:0] digital_tube_segment_n,
    output logic digital_tube_dp_n,
    output logic buzzer_audio,
    output logic funnel_disable,
    output logic motor_enable
);

    // important settings
    logic reset_n;
    assign reset_n = ~reset;

    // buttons part
    logic [4:0] button;
    buttons b_ins (
        .clock(clock),
        .reset_n(reset_n),
        .raw_button(raw_button),
        .button(button)
    );

    // keyboards part
    logic [15:0] keyboard;
    keyboards k_ins (
        .clock(clock),
        .reset_n(reset_n),
        .keyboard_row_n(keyboard_row_n),
        .keyboard_col_n(keyboard_col_n),
        .keyboard(keyboard)
    );

    // controller part
    logic pill_pulse;
    logic pill_disable;
    assign funnel_disable = pill_disable;
    assign motor_enable = ~ pill_disable;
    pill_simulator sim_ins (
        .clock(clock),
        .reset_n(reset_n),
        .strict_enable(strict_enable),
        .pill_disable(pill_disable),
        .pill_pulse(pill_pulse)
    );

    logic [7:0][5:0] display_code;
    logic [31:0] frequency_select;
    controller c_ins (
        .clock(clock),
        .reset_n(reset_n),
        .keyboard(keyboard),
        .button(button),
        .pill(pill_pulse),
        .display_code(display_code),
        .display_dp(),
        .frequency_select(frequency_select),
        .funnel_disable(pill_disable)
    );

    // digital_tube part
    digital_tube dtb_ins (
        .clock(clock),
        .reset_n(reset_n),
        .data_code(display_code),
        .data_dp(0),
        .enable_n(digital_tube_enable_n),
        .segment_n(digital_tube_segment_n),
        .dp_n(digital_tube_dp_n)
    );

    // audio generator part
    audio_generator ag_ins (
        .clock(clock),
        .reset_n(reset_n),
        .frequency_select(frequency_select),
        .audio_output(buzzer_audio)
    );

endmodule
