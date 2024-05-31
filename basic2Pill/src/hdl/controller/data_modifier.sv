`include "config.svh"

module data_modifier (
    input logic clock,
    input logic reset_n,
    input state_t state,
    input logic [1:0] h_ptr,
    input logic [2:0] v_ptr,
    input logic [3:0][3:0] keyboard_down,
    output int jar_cnt [0:3],
    output int one_cnt [0:3],
    output logic keyboard_warning
);
    logic [15:0] reinterpreted_keyboard;

    assign reinterpreted_keyboard['h0] = keyboard_down[3][1];
    assign reinterpreted_keyboard['h1] = keyboard_down[0][0];
    assign reinterpreted_keyboard['h2] = keyboard_down[0][1];
    assign reinterpreted_keyboard['h3] = keyboard_down[0][2];
    assign reinterpreted_keyboard['h4] = keyboard_down[1][0];
    assign reinterpreted_keyboard['h5] = keyboard_down[1][1];
    assign reinterpreted_keyboard['h6] = keyboard_down[1][2];
    assign reinterpreted_keyboard['h7] = keyboard_down[2][0];
    assign reinterpreted_keyboard['h8] = keyboard_down[2][1];
    assign reinterpreted_keyboard['h9] = keyboard_down[2][2];
    assign reinterpreted_keyboard['ha] = keyboard_down[0][3];
    assign reinterpreted_keyboard['hb] = keyboard_down[1][3];
    assign reinterpreted_keyboard['hc] = keyboard_down[2][3];
    assign reinterpreted_keyboard['hd] = keyboard_down[3][3];
    assign reinterpreted_keyboard['he] = keyboard_down[3][2];
    assign reinterpreted_keyboard['hf] = keyboard_down[3][0];

    int keyboard_count;
    int keyboard_number;

    always_comb begin
        keyboard_count = 0;
        for (int i = 0; i < 16; i++)
            if (reinterpreted_keyboard[i])
                keyboard_count = keyboard_count + 1;
    end

    always_comb begin
        keyboard_number = 0;
        for (int i = 0; i < 16; i++)
            if (reinterpreted_keyboard[i])
                keyboard_number = keyboard_number + i;
    end

    assign keyboard_warning = (state == setting_state) && ((keyboard_count > 1) || (keyboard_number > 9));

    always @(posedge clock or negedge reset_n) begin
        if (~ reset_n) begin
            for (int i = 0; i < 4; i++) begin
                jar_cnt[i] <= 0;
                one_cnt[i] <= 0;
            end
        end else begin
            if (state == setting_state && keyboard_count == 1 && keyboard_number <= 9) begin
                case (v_ptr)
                    0: jar_cnt[h_ptr] = keyboard_number;
                    1: one_cnt[h_ptr] = keyboard_number;
                    2: jar_cnt[h_ptr] = keyboard_number;
                    3: one_cnt[h_ptr] = keyboard_number;
                    4: jar_cnt[h_ptr] = keyboard_number;
                endcase
            end
        end
    end

endmodule
