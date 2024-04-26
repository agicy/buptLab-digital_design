parameter lcd_screen_signal_generator_frequency = 40000000;
parameter adjust_signal_frequency = 250;
parameter duty_adjust_numerator = 9;
parameter duty_adjust_denominator = 10;
parameter screen_width = 800;
parameter screen_height = 480;
parameter horizontal_period = 928;
parameter horizontal_valid_count = 800;
parameter vertical_period = 525;
parameter vertical_valid_count = 480;

module lcd_screen_signal_generator (
    input logic clock,
    input logic lcd_screen_dclk,
    input logic reset_n,
    output logic adj,
    output logic mode,
    output logic de,
    output shortint next_x,
    output shortint next_y
);

    // lcd_adj configuration

    logic clock_adjust;
    divider #(
        .divisor(lcd_screen_signal_generator_frequency / (adjust_signal_frequency * duty_adjust_denominator))
    ) adj_div_ins (
        .clock(clock),
        .reset_n(reset_n),
        .clock_out(clock_adjust)
    );

    logic adjust_signal;
    logic [$clog2(duty_adjust_denominator) - 1 : 0] adjust_count;
    counter #(
        .modulus(duty_adjust_denominator)
    ) counter_adjust (
        .clock  (clock_adjust),
        .enable (1'b1),
        .reset_n(reset_n),
        .count  (adjust_count),
        .carry  ()
    );

    assign adjust_signal = (adjust_count >= duty_adjust_numerator) ? 0 : 1;

    // lcd mode control setting

    assign mode = 1'b1;

    // scanning sub-part

    logic[15:0] scanning_x, scanning_y;
    always @(posedge lcd_screen_dclk) begin
        if (scanning_x >= horizontal_period - 1) begin
            scanning_x <= 0;
            if (scanning_y >= vertical_period - 1)
                scanning_y <= 0;
            else
                scanning_y <= scanning_y + 1;
        end else
            scanning_x <= scanning_x + 1;
    end

    always @(posedge lcd_screen_dclk) begin
        if (scanning_x + 1 > horizontal_period - 1) begin
            next_x <= 0;
            if (scanning_y + 1 > vertical_period - 1)
                next_y <= 0;
            else
                next_y <= scanning_y + 1;
        end else
            next_x <= scanning_x + 1;
    end

    logic h_valid, v_valid;
    assign h_valid = scanning_x < horizontal_valid_count ? 1 : 0;
    assign v_valid = scanning_y < vertical_valid_count ? 1 : 0;
    logic data_enable;
    assign data_enable = h_valid && v_valid;

    // mapping port part

    assign adj = adjust_signal;
    assign de = data_enable;

endmodule
