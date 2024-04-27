`include "config.svh"

module audio_output_generator (
    input logic clock,
    input logic reset_n,
    input logic no_response,
    input logic game_over,
    input logic food_eating,
    input logic warning,
    output logic [31:0] frequency_select
);

    logic game_over_working;
    logic [31:0] game_over_address;
    logic [31:0] game_over_music_data[0:31] = {
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

    logic food_eating_working;
    logic [31:0] food_eating_address;
    logic [31:0] food_eating_music_data[0:1] = {0, 35};

    logic warning_working;
    logic [31:0] warning_address;
    logic [31:0] warning_music_data[0:1] = {35, 0};

    localparam ticking = `frequency / (4 * `audio_bps);
    logic [$clog2(ticking)-1:0] ms;
    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            ms = 0;
            game_over_working = 0;
            game_over_address = 0;
            food_eating_working = 0;
            food_eating_address = 0;
            warning_working = 0;
            warning_address = 0;
        end else begin
            casex ({
                no_response, game_over, food_eating, warning
            })
                4'b1xxx: begin
                    ms = 0;
                    game_over_working = 0;
                    game_over_address = 0;
                    food_eating_working = 0;
                    food_eating_address = 0;
                    warning_working = 0;
                    warning_address = 0;
                end
                4'b01xx: begin
                    if (~game_over_working) begin
                        ms = 0;
                        game_over_working = 1;
                        game_over_address = 0;
                        food_eating_working = 0;
                        food_eating_address = 0;
                        warning_working = 0;
                        warning_address = 0;
                    end
                end
                4'b001x: begin
                    if (~food_eating_working) begin
                        ms = 0;
                        game_over_working = 0;
                        game_over_address = 0;
                        food_eating_working = 1;
                        food_eating_address = 0;
                        warning_working = 0;
                        warning_address = 0;
                    end
                end
                4'b0001: begin
                    if (~warning_working) begin
                        ms = 0;
                        game_over_working = 0;
                        game_over_address = 0;
                        food_eating_working = 0;
                        food_eating_address = 0;
                        warning_working = 1;
                        warning_address = 0;
                    end
                end
            endcase

            if (|{game_over_working, food_eating_working, warning_working}) begin
                if (ms == ticking - 1) begin
                    ms = 0;
                    case ({
                        game_over_working, food_eating_working, warning_working
                    })
                        3'b100: begin
                            if (game_over_address >= $size(game_over_music_data) - 1) begin
                                game_over_working = 0;
                                game_over_address = 0;
                            end else begin
                                game_over_address = game_over_address + 1;
                            end
                        end
                        3'b010: begin
                            if (food_eating_address >= $size(food_eating_music_data) - 1) begin
                                food_eating_working = 0;
                                food_eating_address = 0;
                            end else begin
                                food_eating_address = food_eating_address + 1;
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
            game_over_working, food_eating_working, warning_working
        })
            3'b100:  frequency_select <= game_over_music_data[game_over_address];
            3'b010:  frequency_select <= food_eating_music_data[food_eating_address];
            3'b001:  frequency_select <= warning_music_data[warning_address];
            default: frequency_select <= ~0;
        endcase
    end

endmodule
