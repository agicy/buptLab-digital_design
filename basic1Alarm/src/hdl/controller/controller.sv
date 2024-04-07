`include "config.svh"

module controller (
    input logic clock,
    input logic reset_n,
    input logic [15:0] keyboard,
    input logic [4:0] button,
    output logic [7:0][5:0] display_code,
    output logic [31:0] frequency_select
);

    logic clock_controller;
    assign clock_controller = clock;

    // Timing generating part

    logic T[0:3];
    timing #(
        .timing_count(4)
    ) timer (
        .clock(clock_controller),
        .reset_n(reset_n),
        .clock_out(T)
    );

    // Part 0

    logic [15:0] keyboard_down;
    logic [4:0] button_down;
    input_receiver ir_ins (
        .clock(T[0]),
        .reset_n(reset_n),
        .keyboard(keyboard),
        .button(button),
        .keyboard_down(keyboard_down),
        .button_down(button_down)
    );

    // Part 1

    state_t state;
    state_machine sm_ins (
        .clock(T[1]),
        .reset_n(reset_n),
        .switch_signal(button_down[3]),
        .state(state)
    );

    logic [2:0] h_ptr;
    pointer_modifier #(
        .modulus(6)
    ) hpm_ins (
        .clock(T[1]),
        .reset_n(reset_n),
        .add(button_down[1]),
        .sub(button_down[0]),
        .pointer(h_ptr)
    );

    logic [1:0] v_ptr;
    pointer_modifier #(
        .modulus(4)
    ) vpm_ins (
        .clock(T[1]),
        .reset_n(reset_n),
        .add(button_down[4]),
        .sub(button_down[2]),
        .pointer(v_ptr)
    );

    // Part 2

    logic [23:0] time_data;
    logic [3:0][23:0] alarm_data;
    logic [3:0] is_activated;
    logic keyboard_warning;
    logic zero_ms;
    data_modifier dm_ins (
        .clock(T[2]),
        .reset_n(reset_n),
        .state(state),
        .h_ptr(h_ptr),
        .v_ptr(v_ptr),
        .keyboard_down(keyboard_down),
        .time_data(time_data),
        .alarm_data(alarm_data),
        .is_activated(is_activated),
        .keyboard_warning(keyboard_warning),
        .zero_ms(zero_ms)
    );

    logic pointer_warning;
    assign pointer_warning = (button_down[0] & button_down[1]) | (button_down[2] & button_down[4]);

    logic [3:0] alarm_signal;
    logic alarm;
    logic oclock;
    logic warning;
    logic no_response;

    generate
        for (genvar i = 0; i < 4; i++) begin : ac_ins
            alarm_comparator ac_ins (
                .time_data(time_data),
                .alarm_data(alarm_data[i]),
                .is_activated(is_activated[i]),
                .alarm_signal(alarm_signal[i])
            );
        end
    endgenerate

    assign alarm = (|alarm_signal) & zero_ms;  // ?
    assign oclock = (~(|{time_data[15:0]})) & zero_ms;
    assign warning = keyboard_warning | pointer_warning;
    assign no_response = |button_down;

    // Part 3

    display_data_generator ddg_ins (
        .clock(T[3]),
        .reset_n(reset_n),
        .state(state),
        .h_ptr(h_ptr),
        .v_ptr(v_ptr),
        .time_data(time_data),
        .alarm_data(alarm_data),
        .is_activated(is_activated),
        .display_code(display_code)
    );

    audio_output_generator aog_ins (
        .clock(T[3]),
        .reset_n(reset_n),
        .no_response(no_response),
        .alarm(alarm),
        .oclock(oclock),
        .warning(warning),
        .frequency_select(frequency_select)
    );

endmodule

module alarm_comparator (
    input logic [23:0] time_data,
    input logic [23:0] alarm_data,
    input logic is_activated,
    output logic alarm_signal
);

    assign alarm_signal = is_activated & (time_data == alarm_data);

endmodule
