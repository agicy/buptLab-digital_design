`include "config.svh"

module state_machine (
    input logic clock,
    input logic reset_n,
    input logic [4:0] button_down,
    input snake_t snake,
    input logic lose_logic,
    output state_t state,
    output direction_t direction,
    output logic [$clog2(`tick)-1:0] ms_count,
    output logic no_response,
    output logic game_over,
    output logic warning
);

    logic state_switch;
    logic [3:0] direction_switch_vector;
    assign state_switch = button_down[3];
    assign direction_switch_vector = {
        button_down[0], button_down[1], button_down[2], button_down[4]
    };

    // handle state transition

    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            state <= initial_state;
        end else begin
            if (lose_logic & state != over_state) begin
                state <= over_state;
            end else if (state_switch) begin
                case (state)
                    initial_state: state <= pause_state;
                    pause_state: state <= pause_state;
                    game_state: state <= pause_state;
                    over_state: state <= initial_state;
                endcase
            end else if (|direction_switch_vector) begin
                if (state == pause_state || state == game_state) begin
                    state <= game_state;
                end
            end else begin
                state <= state;
            end
        end
    end

    // handle direction transition

    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            warning <= 0;
            direction <= none; // it does not make sense
        end else begin
            if (state == initial_state)
                direction <= none;
            else
                case (direction_switch_vector)
                    4'b1000: begin
                        // right
                        if (snake.length > 2 && direction == left)
                            warning = 1;
                        else begin
                            warning = 0;
                            direction = right;
                        end
                    end
                    4'b0100: begin
                        // left
                        if (snake.length > 2 && direction == right)
                            warning = 1;
                        else begin
                            warning = 0;
                            direction = left;
                        end
                    end
                    4'b0010: begin
                        // up
                        if (snake.length > 2 && direction == down)
                            warning = 1;
                        else begin
                            warning = 0;
                            direction = up;
                        end
                    end
                    4'b0001: begin
                        // down
                        if (snake.length > 2 && direction == up)
                            warning = 1;
                        else begin
                            warning = 0;
                            direction = down;
                        end
                    end
                    default: begin
                        warning = 0;
                        direction = direction;
                    end
                endcase
        end
    end

    // handle ticking

    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            ms_count <= 0;
        end else begin
            if (ms_count == `tick - 1) begin
                ms_count <= 0;
            end else begin
                ms_count <= ms_count + 1;
            end
        end
    end

    // handle audio signals

    assign no_response = (state == initial_state) ? 1 : 0;
    assign game_over = (state == over_state) ? 1 : 0;

endmodule
