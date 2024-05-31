`include "config.svh"

module audio_output_generator (
    input logic clock,
    input logic reset_n,
    input logic no_response,
    input logic music,
    input logic error,
    input logic warning,
    output logic [31:0] frequency_select
);

    logic music_working;
    logic [31:0] music_address;
    logic [31:0] music_data[0:31] = {
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

    logic error_working;
    logic [31:0] error_address;
    logic [31:0] error_beep_data[0:1] = {35, 0};

    logic warning_working;
    logic [31:0] warning_address;
    logic [31:0] warning_beep_data[0:1] = {35, 0};

    localparam ticking = 100000000 / (4 * `audio_bps);
    logic [$clog2(ticking)-1:0] ms;
    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            ms = 0;
            music_working = 0;
            music_address = 0;
            error_working = 0;
            error_address = 0;
            warning_working = 0;
            warning_address = 0;
        end else begin
            casex ({
                no_response, music, error, warning
            })
                4'b1xxx: begin
                    ms = 0;
                    music_working = 0;
                    music_address = 0;
                    error_working = 0;
                    error_address = 0;
                    warning_working = 0;
                    warning_address = 0;
                end
                4'b01xx: begin
                    if (~music_working) begin
                        ms = 0;
                        music_working = 1;
                        music_address = 0;
                        error_working = 0;
                        error_address = 0;
                        warning_working = 0;
                        warning_address = 0;
                    end
                end
                4'b001x: begin
                    if (~error_working) begin
                        ms = 0;
                        music_working = 0;
                        music_address = 0;
                        error_working = 1;
                        error_address = 0;
                        warning_working = 0;
                        warning_address = 0;
                    end
                end
                4'b0001: begin
                    if (~warning_working) begin
                        ms = 0;
                        music_working = 0;
                        music_address = 0;
                        error_working = 0;
                        error_address = 0;
                        warning_working = 1;
                        warning_address = 0;
                    end
                end
            endcase

            if (|{music_working, error_working, warning_working}) begin
                if (ms == ticking - 1) begin
                    ms = 0;
                    case ({
                        music_working, error_working, warning_working
                    })
                        3'b100: begin
                            if (music_address >= $size(music_data) - 1) begin
                                music_working = 0;
                                music_address = 0;
                            end else begin
                                music_address = music_address + 1;
                            end
                        end
                        3'b010: begin
                            if (error_address >= $size(error_beep_data) - 1) begin
                                error_working = 0;
                                error_address = 0;
                            end else begin
                                error_address = error_address + 1;
                            end
                        end
                        3'b001: begin
                            if (warning_address >= $size(warning_beep_data) - 1) begin
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

    always_comb begin
        case ({
            music_working, error_working, warning_working
        })
            3'b100:  frequency_select <= music_data[music_address];
            3'b010:  frequency_select <= error_beep_data[error_address];
            3'b001:  frequency_select <= warning_beep_data[warning_address];
            default: frequency_select <= ~0;
        endcase
    end

endmodule
