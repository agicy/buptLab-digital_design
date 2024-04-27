`include "config.svh"

module snake_modifier(
    input logic clock,
    input logic reset_n,
    input state_t state,
    input direction_t direction,
    input logic [$clog2(`tick)-1:0] ms_count,
    input logic [31:0] random_number_1,
    input logic [31:0] random_number_2,
    output snake_t snake,
    output point_t food,
    output logic has_food,
    output logic food_eaten,
    output logic lose_logic
);

    int snake_body_select;
    always @(posedge clock or negedge reset_n)
        if (~ reset_n)
            snake_body_select <= 0;
        else
            if (snake_body_select >= snake.length - 1)
                snake_body_select <= 0;
            else
                snake_body_select <= snake_body_select + 1;

    always @(posedge clock or negedge reset_n)
        if (~reset_n) begin
            snake.length <= 1;
            for (int i = 0; i < `max_length; i++)
                snake.array[i] <= '{x: `screen_width/2, y: `screen_height/2};
            has_food <= 0;
            food <= '{x: 0, y: 0};
            food_eaten <= 0;
        end else begin
            case (state)
                initial_state: begin
                    snake.length = 1;
                    snake.array[0] = '{x: `screen_width/2, y: `screen_height/2};
                    has_food = 0;
                end
                game_state: begin
                    if (~ has_food) begin
                        food = '{x: random_number_1 % `screen_width, y: random_number_2 % `screen_height};
                        if (~ food_eating(food, snake)) begin
                            has_food = 1;
                        end
                    end
                    if (ms_count == 0) begin
                        for (int i = `max_length - 2; i >= 0; i--)
                            snake.array[i+1] = snake.array[i];
                        case (direction)
                            up: snake.array[0] = step_up(snake.array[0]);
                            down: snake.array[0] = step_down(snake.array[0]);
                            left: snake.array[0] = step_left(snake.array[0]);
                            right: snake.array[0] = step_right(snake.array[0]);
                        endcase
                    end
                    if (has_food && food_eating(food, snake)) begin
                        has_food = 0;
                        snake.length = snake.length + 1;
                        food_eaten = 1;
                    end else begin
                        food_eaten = 0;
                    end
                end
            endcase
        end

    always @(posedge clock or negedge reset_n)
        if (~ reset_n)
            lose_logic <= 0;
        else
            lose_logic <= (state != initial_state) && (lose_logic | (snake_body_select && in_circle(snake.array[0], snake.array[snake_body_select], `snake_body_size)));

endmodule
