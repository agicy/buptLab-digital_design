`include "config.svh"

module input_receiver (
    input logic clock,
    input logic reset_n,
    input logic [15:0] keyboard,
    input logic [4:0] button,
    input logic pill,
    output logic [15:0] keyboard_down,
    output logic [4:0] button_down,
    output logic pill_pulse
);

    logic [15:0] last_keyboard;
    always @(posedge clock or negedge reset_n) begin
        if (~ reset_n) begin
            keyboard_down <= 'b0;
            last_keyboard <= 'b0;
        end else begin
            keyboard_down = (~ last_keyboard) & keyboard;
            last_keyboard = keyboard;
        end
    end

    logic [4:0] last_button;
    always @(posedge clock or negedge reset_n) begin
        if (~ reset_n) begin
            button_down <= 'b0;
            last_button <= 'b0;
        end else begin
            button_down = (~ last_button) & button;
            last_button = button;
        end
    end

    logic last_pill;
    always @(posedge clock or negedge reset_n) begin
        if (~ reset_n) begin
            pill_pulse <= 'b0;
            last_pill <= 'b0;
        end else begin
            pill_pulse = (~ last_pill) & pill;
            last_pill = pill;
        end
    end

endmodule
