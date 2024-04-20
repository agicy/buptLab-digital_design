`include "config.svh"

module audio_output_generator (
    input logic clock,
    input logic reset_n,
    input logic no_response,
    input logic alarm,
    input logic oclock,
    input logic warning,
    output logic [31:0] frequency_select
);

    logic alarm_working;
    logic [31:0] alarm_address;
    logic [31:0] alarm_music_data[0:31] = {
        9,
        12,
        16,
        20,
        16,
        16,
        16,
        15,
        16,
        16,
        16,
        15,
        16,
        16,
        9,
        11,
        12,
        16,
        15,
        12,
        9,
        9,
        8,
        8,
        4,
        4,
        4,
        4,
        4,
        4,
        4,
        4
    };

    logic oclock_working;
    logic [31:0] oclock_address;
    logic [31:0] oclock_music_data[0:6] = {12, 14, 16, 17, 19, 21, 23};

    logic warning_working;
    logic [31:0] warning_address;
    logic [31:0] warning_music_data[0:1] = {35, 0};

    localparam ticking = `frequency / (4 * `audio_bps);
    logic [$clog2(ticking)-1:0] ms;
    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            ms = 0;
            alarm_working = 0;
            alarm_address = 0;
            oclock_working = 0;
            oclock_address = 0;
            warning_working = 0;
            warning_address = 0;
        end else begin
            casex ({
                no_response, alarm, oclock, warning
            })
                4'b1xxx: begin
                    ms = 0;
                    alarm_working = 0;
                    alarm_address = 0;
                    oclock_working = 0;
                    oclock_address = 0;
                    warning_working = 0;
                    warning_address = 0;
                end
                4'b01xx: begin
                    if (~alarm_working) begin
                        ms = 0;
                        alarm_working = 1;
                        alarm_address = 0;
                        oclock_working = 0;
                        oclock_address = 0;
                        warning_working = 0;
                        warning_address = 0;
                    end
                end
                4'b001x: begin
                    if (~oclock_working) begin
                        ms = 0;
                        alarm_working = 0;
                        alarm_address = 0;
                        oclock_working = 1;
                        oclock_address = 0;
                        warning_working = 0;
                        warning_address = 0;
                    end
                end
                4'b0001: begin
                    if (~warning_working) begin
                        ms = 0;
                        alarm_working = 0;
                        alarm_address = 0;
                        oclock_working = 0;
                        oclock_address = 0;
                        warning_working = 1;
                        warning_address = 0;
                    end
                end
            endcase

            if (|{alarm_working, oclock_working, warning_working}) begin
                if (ms == ticking - 1) begin
                    ms = 0;
                    case ({
                        alarm_working, oclock_working, warning_working
                    })
                        3'b100: begin
                            if (alarm_address >= $size(alarm_music_data) - 1) begin
                                alarm_working = 0;
                                alarm_address = 0;
                            end else begin
                                alarm_address = alarm_address + 1;
                            end
                        end
                        3'b010: begin
                            if (oclock_address >= $size(oclock_music_data) - 1) begin
                                oclock_working = 0;
                                oclock_address = 0;
                            end else begin
                                oclock_address = oclock_address + 1;
                            end
                        end
                        3'b001: begin
                            if (warning_address >= $size(warning_music_data) - 1) begin
                                warning_working = 0;
                                warning_address = 0;
                            end else begin
                                warning_address = warning_address + 1;
                            end
                        end
                    endcase
                end else begin
                    ms = ms + 1;
                end
            end
        end
    end

    always @(*) begin
        case ({
            alarm_working, oclock_working, warning_working
        })
            3'b100:  frequency_select <= alarm_music_data[alarm_address];
            3'b010:  frequency_select <= oclock_music_data[oclock_address];
            3'b001:  frequency_select <= warning_music_data[warning_address];
            default: frequency_select <= ~0;
        endcase
    end

endmodule
