`include "config.svh"

module display_data_generator (
    input logic clock,
    input logic reset_n,
    input state_t state,
    input logic [2:0] h_ptr,
    input logic [1:0] v_ptr,
    input logic [23:0] time_data,
    input logic [95:0] alarm_data,
    input logic [3:0] is_activated,
    output logic [7:0][5:0] display_code
);
    logic [5:0][3:0] __time_data;
    assign __time_data = time_data;
    logic [3:0][5:0][3:0] __alarm_data;
    assign __alarm_data = alarm_data;

    localparam divisor = `frequency / 4 / `frequency_fliping;

    logic flip;
    divider #(divisor) flip_ins (
        .clock(clock),
        .reset_n(reset_n),
        .clock_out(flip)
    );

    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            display_code <= 0;
        end else begin
            case (state)
                normal_state: begin
                    display_code[7] = |is_activated ? 6'ha : ~'b0;
                    display_code[6] = ~'b0;
                    for (int i = 0; i < 6; i++) begin
                        display_code[i] = {2'b00, __time_data[i]};
                    end
                end
                time_setting_state: begin
                    display_code[7] = ~'b0;
                    display_code[6] = ~'b0;
                    for (int i = 0; i < 6; i++) begin
                        display_code[i] = (flip && i == h_ptr) ? (~'b0) : {2'b00, __time_data[i]};
                    end
                end
                alarm_setting_state: begin
                    display_code[7] = is_activated[v_ptr] ? 6'ha : ~'b0;
                    display_code[6] = v_ptr;
                    for (int i = 0; i < 6; i++) begin
                        display_code[i] = (flip && i == h_ptr) ? (~ 'b0) : {2'b00, __alarm_data[v_ptr][i]};
                    end
                end
                default: display_code = ~'b0;
            endcase
        end
    end
endmodule
