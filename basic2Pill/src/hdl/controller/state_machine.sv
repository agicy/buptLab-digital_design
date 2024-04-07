`include "config.svh"

module state_machine (
    input logic clock,
    input logic reset_n,
    input logic switch_signal,
    input logic error_signal,
    input logic complete_signal,
    output state_t state
);

    always_ff @(posedge clock or negedge reset_n) begin
        if (~ reset_n)
            state <= setting_state;
        else
            case (state)
                setting_state:
                    state <= switch_signal ? working_state : setting_state;
                working_state:
                    if (error_signal)
                        state <= error_state;
                    else
                        if (complete_signal)
                            state <= final_state;
                        else
                            if (switch_signal)
                                state <= pause_state;
                            else
                                state <= state;
                pause_state:
                    if (error_signal)
                        state <= error_state;
                    else
                        if (complete_signal)
                            state <= final_state;
                        else
                            if (switch_signal)
                                state <= working_state;
                            else
                                state <= state;
                error_state:
                    state <= switch_signal ? setting_state : error_state;
                final_state:
                    state <= switch_signal ? setting_state : final_state;
                default: 
                    state <= setting_state;
            endcase
    end
endmodule
