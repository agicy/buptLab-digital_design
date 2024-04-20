`include "config.svh"

module data_modifier (
    input logic clock,
    input logic reset_n,
    input state_t state,
    input logic [2:0] h_ptr,
    input logic [1:0] v_ptr,
    input logic [3:0][3:0] keyboard_down,
    output logic [5:0][3:0] time_data,
    output logic [3:0][5:0][3:0] alarm_data,
    output logic [3:0] is_activated,
    output logic keyboard_warning,
    output logic zero_ms
);

    logic [5:0] keyboard_down_count;
    always @(*) begin
        keyboard_down_count = 0;
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                keyboard_down_count = keyboard_down_count + keyboard_down[i][j];
    end

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

    logic [3:0] keyboard_down_number;
    always @(*) begin
        keyboard_down_number = 0;
        for (int i = 0; i < 16; i++)
            if (reinterpreted_keyboard[i])
                keyboard_down_number = keyboard_down_number | $unsigned(i);
    end

    localparam ms_count = `frequency / 4;
    logic [$clog2(ms_count)-1:0] ms;

    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            ms <= 0;
            time_data <= 0;
            for (int i = 0; i < 4; i++) begin
                alarm_data[i] <= 0;
                is_activated[i] <= 0;
            end
            keyboard_warning <= 0;
        end else begin
            keyboard_warning = 0;
            if (state == time_setting_state) begin
                if (keyboard_down_count == 1) begin
                    case (h_ptr)
                        0:
                        if (keyboard_down_number < 10) begin
                            time_data[0] = keyboard_down_number;
                            ms = 0;
                        end else
                            keyboard_warning = 1;
                        1:
                        if (keyboard_down_number < 6)
                            time_data[1] = keyboard_down_number;
                        else
                            keyboard_warning = 1;
                        2:
                        if (keyboard_down_number < 10)
                            time_data[2] = keyboard_down_number;
                        else
                            keyboard_warning = 1;
                        3:
                        if (keyboard_down_number < 6)
                            time_data[3] = keyboard_down_number;
                        else
                            keyboard_warning = 1;
                        4:
                        if (time_data[5] < 2 && keyboard_down_number < 10 || time_data[5] == 2 && keyboard_down_number < 4)
                            time_data[4] = keyboard_down_number;
                        else
                            keyboard_warning = 1;
                        5:
                        if (keyboard_down_number < 2 || keyboard_down_number == 2 && time_data[4] < 4)
                            time_data[5] = keyboard_down_number;
                        else
                            keyboard_warning = 1;
                    endcase
                end else if (keyboard_down_count)
                    keyboard_warning = 1;
            end

            if (state == alarm_setting_state) begin
                if (keyboard_down_count == 1) begin
                    if (keyboard_down_number < 10)
                        case (h_ptr)
                            0: alarm_data[v_ptr][0] = keyboard_down_number;
                            1:
                            if (keyboard_down_number < 6)
                                alarm_data[v_ptr][1] = keyboard_down_number;
                            else
                                keyboard_warning = 1;
                            2: alarm_data[v_ptr][2] = keyboard_down_number;
                            3:
                            if (keyboard_down_number < 6)
                                alarm_data[v_ptr][3] = keyboard_down_number;
                            else
                                keyboard_warning = 1;
                            4:
                            if (alarm_data[v_ptr][5] < 2 || alarm_data[v_ptr][5] == 2 && keyboard_down_number < 4)
                                alarm_data[v_ptr][4] = keyboard_down_number;
                            else
                                keyboard_warning = 1;
                            5:
                            if (keyboard_down_number < 2 || keyboard_down_number == 2 && alarm_data[v_ptr][4] < 4)
                                alarm_data[v_ptr][5] = keyboard_down_number;
                            else
                                keyboard_warning = 1;
                        endcase
                    else
                        is_activated[v_ptr] = ~is_activated[v_ptr];
                end else if (keyboard_down_count)
                    keyboard_warning = 1;
            end

            if (ms == ms_count - 1) begin
                ms = 0;
                if (time_data[0] == 10 - 1) begin
                    time_data[0] = 0;
                    if (time_data[1] == 6 - 1) begin
                        time_data[1] = 0;
                        if (time_data[2] == 10 - 1) begin
                            time_data[2] = 0;
                            if (time_data[3] == 6 - 1) begin
                                time_data[3] = 0;
                                if (time_data[5] == 2 && time_data[4] == 3) begin
                                    time_data[4] = 0;
                                    time_data[5] = 0;
                                end else if (time_data[4] == 9)
                                    time_data[5] = time_data[5] + 1;
                                else
                                    time_data[4] = time_data[4] + 1;
                            end else
                                time_data[3] = time_data[3] + 1;
                        end else
                            time_data[2] = time_data[2] + 1;
                    end else
                        time_data[1] = time_data[1] + 1;
                end else
                    time_data[0] = time_data[0] + 1;
            end else
                ms = ms + 1;
        end
    end

    assign zero_ms = ~ (| ms);

endmodule
