`include "config.svh"

module top_module (
    input logic clock,
    input logic reset,
    input logic [4:0] raw_button,
    output logic lcd_screen_adj,
    output logic lcd_screen_mode,
    output logic lcd_screen_de,
    output logic lcd_screen_dclk,
    output logic [2:0] lcd_screen_r,
    output logic [1:0] lcd_screen_g,
    output logic [2:0] lcd_screen_b,
    output logic [7:0] digital_tube_enable_n,
    output logic [6:0] digital_tube_segment_n,
    output logic digital_tube_dp_n,
    output logic buzzer_output
);

    logic clock_out;
    clock_generator clock_generator(
        .controller_phase0(controller_phase0),
        .controller_phase1(controller_phase1),
        .controller_phase2(controller_phase2),
        .controller_phase3(controller_phase3),
        .lcd_screen_dclk(lcd_screen_dclk),
        .clock_out(clock_out),
        .reset(reset),
        .locked(),
        .clock_in(clock)
    );

    // important settings

    logic reset_n;
    assign reset_n = ~reset;

    // buttons part

    logic [4:0] button;
    buttons b_ins (
        .clock(clock_out),
        .reset_n(reset_n),
        .raw_button(raw_button),
        .button(button)
    );

    // lcd_screen part

    logic [15:0] x;
    logic [15:0] y;
    lcd_screen_signal_generator lssg_inv (
        .clock(clock_out),
        .lcd_screen_dclk(lcd_screen_dclk),
        .reset_n(reset_n),
        .adj(lcd_screen_adj),
        .mode(lcd_screen_mode),
        .de(lcd_screen_de),
        .next_x(x),
        .next_y(y)
    );

    // controller part

    logic [31:0] snake_length;
    logic [31:0] frequency_select;
    controller ctrl_ins (
        .clock(clock_out),
        .controller_phase0(controller_phase0),
        .controller_phase1(controller_phase1),
        .controller_phase2(controller_phase2),
        .controller_phase3(controller_phase3),
        .lcd_screen_dclk(lcd_screen_dclk),
        .reset_n(reset_n),
        .button(button),
        .frequency_select(frequency_select),
        .snake_length(snake_length),
        .screen_point('{x: x, y: y}),
        .screen_r(lcd_screen_r),
        .screen_g(lcd_screen_g),
        .screen_b(lcd_screen_b)
    );

    // digital_tube part

    logic [5:0] display_number0;
    assign display_number0 = snake_length % 10;
    logic [5:0] display_number1;
    assign display_number1 = snake_length / 10 % 10;
    logic [5:0] display_number2;
    assign display_number2 = snake_length / 100;

    digital_tube dtb_ins (
        .clock(clock_out),
        .reset_n(reset_n),
        .data_code({
            ~6'h0, ~6'h0, ~6'h0, ~6'h0, ~6'h0, display_number2, display_number1, display_number0
        }),
        .data_dp(8'b0),
        .enable_n(digital_tube_enable_n),
        .segment_n(digital_tube_segment_n),
        .dp_n(digital_tube_dp_n)
    );

    // audio_generator part

    audio_generator ag_ins (
        .clock(clock_out),
        .reset_n(reset_n),
        .frequency_select(frequency_select),
        .audio_output(buzzer_output)
    );

endmodule
