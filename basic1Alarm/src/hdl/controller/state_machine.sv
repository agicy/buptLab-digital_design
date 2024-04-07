`include "config.svh"

module state_machine (
    input  logic   clock,
    input  logic   reset_n,
    input  logic   switch_signal,
    output state_t state
);
    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            state <= normal_state;
        end else begin
            if (switch_signal) begin
                case (state)
                    normal_state: state <= time_setting_state;
                    time_setting_state: state <= alarm_setting_state;
                    alarm_setting_state: state <= normal_state;
                    default state <= normal_state;
                endcase
            end else begin
                case (state)
                    normal_state: state <= normal_state;
                    time_setting_state: state <= time_setting_state;
                    alarm_setting_state: state <= alarm_setting_state;
                    default: state <= normal_state;
                endcase
            end
        end
    end
endmodule
