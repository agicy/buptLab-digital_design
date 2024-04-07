`include "config.svh"

module controller (
    input logic clock,
    input logic reset_n,
    input logic [15:0] keyboard,
    input logic [4:0] button,
    input logic pill,

    output logic [7:0][5:0] display_code,
    output logic [7:0] display_dp,
    output logic [31:0] frequency_select,
    output logic funnel_disable
);

    logic T [0:3];
    timing #(
        .timing_count(4)
    ) timing_ins (
        .clock(clock),
        .reset_n(reset_n),
        .clock_out(T)
    );

    // Part 0: input

    logic [15:0] keyboard_down;
    logic [4:0] button_down;
    logic pill_pulse;
    input_receiver ir_ins (
        .clock(T[0]),
        .reset_n(reset_n),
        .keyboard(keyboard),
        .button(button),
        .pill(pill),
        .keyboard_down(keyboard_down),
        .button_down(button_down),
        .pill_pulse(pill_pulse)
    );
    
    // Part 1 state machine + pointer

    state_t state;
    logic switch_signal;
    assign switch_signal = button_down[3];
    logic complete_signal;
    state_machine sm_ins (
        .clock(T[1]),
        .reset_n(reset_n),
        .switch_signal(switch_signal),
        .error_signal(error_signal),
        .complete_signal(complete_signal),
        .state(state)
    );

    logic [1:0] h_ptr;
    pointer_modifier #(.modulus(4)) hpm_ins (
        .clock(T[1]),
        .reset_n(reset_n),
        .add(button_down[1]),
        .sub(button_down[0]),
        .pointer(h_ptr)
    );

    logic [2:0] v_ptr;
    pointer_modifier #(.modulus(5)) vpm_ins (
        .clock(T[1]),
        .reset_n(reset_n),
        .add(button_down[4]),
        .sub(button_down[2]),
        .pointer(v_ptr)
    );

    // Part 2: data
    
    int jar_cnt [0:3];
    int one_cnt [0:3];
    int jar_number;
    assign jar_number = ((jar_cnt[3] * 10 + jar_cnt[2]) * 10 + jar_cnt[1]) * 10 + jar_cnt[0];
    int one_number;
    assign one_number = ((one_cnt[3] * 10 + one_cnt[2]) * 10 + one_cnt[1]) * 10 + one_cnt[0];
    logic keyboard_warning;

    data_modifier dm_ins (
        .clock(T[2]),
        .reset_n(reset_n),
        .state(state),
        .h_ptr(h_ptr),
        .v_ptr(v_ptr),
        .jar_cnt(jar_cnt),
        .one_cnt(one_cnt),
        .keyboard_down(keyboard_down),
        .keyboard_warning(keyboard_warning)
    );

    int now_count;
    int now_jar_count;
    localparam tick_limit = `frequency / 4 * 2;
    int tick;
    int total_pill;
    logic funnel_error;
    always_ff @(posedge T[2] or negedge reset_n) begin
        if (~ reset_n) begin
            now_count <= 0;
            now_jar_count <= 0;
            total_pill <= 0;
            tick <= tick_limit - 1;
            funnel_error <= 0;
            complete_signal <= 0;
        end
        else if (state == working_state || state == pause_state) begin
            if (pill_pulse)
                if (state != working_state || now_count == one_number)
                    funnel_error = 1;
                else begin
                    total_pill = total_pill + 1;
                    now_count = now_count + 1;
                    if (now_count == one_number)
                        tick = tick_limit - 1;
                end
            else if (tick) begin
                if (tick == 1) begin
                    tick = 0;
                    now_count = 0;
                    if (now_jar_count == jar_number)
                        complete_signal = 1;
                    now_jar_count = now_jar_count + 1;
                end else
                    tick = tick - 1;
            end
        end else if (state == setting_state) begin
            now_count <= 0;
            now_jar_count <= 0;
            total_pill <= 0;
            tick <= tick_limit - 1;
            funnel_error <= 0;
            complete_signal <= 0;
        end
    end

    assign funnel_disable = (state != working_state) || tick;
    assign error_signal = funnel_error || (! jar_number) || (! one_number);

    // Part 3: output
    display_data_generator ddg_ins (
        .clock(T[3]),
        .reset_n(reset_n),
        .state(state),
        .h_ptr(h_ptr),
        .v_ptr(v_ptr),
        .jar_number(jar_number),
        .one_number(one_number),
        .now_count(now_count),
        .now_jar_count(now_jar_count),
        .total_pill(total_pill),
        
        .display_code(display_code),
        .display_dp(display_dp)
    );

    logic music;
    assign music = (state == final_state);
    logic error;
    assign error = (state == error_state);
    logic warning;
    assign warning = keyboard_warning;
    
    audio_output_generator aog_ins (
        .clock(T[3]),
        .reset_n(reset_n),
        .no_response(button_down[3]),
        .music(music),
        .error(error),
        .warning(warning),
        .frequency_select(frequency_select)
    );

endmodule
