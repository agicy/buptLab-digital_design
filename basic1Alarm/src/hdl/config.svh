`ifndef _GLOBAL_CONFIGURATION_H_
`define _GLOBAL_CONFIGURATION_H_

typedef enum logic [1:0] {
    normal_state,
    time_setting_state,
    alarm_setting_state
} state_t;

`define frequency 100000000
`define frequency_fliping 4
`define audio_bps 4

`endif
