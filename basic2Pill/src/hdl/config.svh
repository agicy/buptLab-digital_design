`ifndef _GLOBAL_CONFIGURATION_H_
`define _GLOBAL_CONFIGURATION_H_

typedef enum logic [2:0] {
    setting_state,
    working_state,
    pause_state,
    error_state,
    final_state
} state_t;

`define frequency 100000000
`define frequency_fliping 4
`define audio_bps 4

`endif
