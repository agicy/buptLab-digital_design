`include "config.svh"

module controller (
    input logic clock,
    input logic controller_phase0,
    input logic controller_phase1,
    input logic controller_phase2,
    input logic controller_phase3,
    input logic lcd_screen_dclk,
    input logic reset_n,
    input logic [4:0] button,
    output logic [31:0] frequency_select,
    input point_t screen_point,
    output logic [31:0] snake_length,
    output logic [2:0] screen_r,
    output logic [1:0] screen_g,
    output logic [2:0] screen_b
);

    snake_t snake;

    assign snake_length = snake.length;

    point_t food;

    // Part 0

    logic [4:0] button_down;
    input_receiver ir_ins (
        .clock(controller_phase0),
        .reset_n(reset_n),
        .button(button),
        .button_down(button_down)
    );

    logic [31:0] random_number_1;
    random_engine re_ins_1 (
        .clock(controller_phase0),
        .reset_n(reset_n),
        .random_number(random_number_1)
    );

    logic [31:0] random_number_2;
    random_engine re_ins_2 (
        .clock(controller_phase0),
        .reset_n(reset_n),
        .random_number(random_number_2)
    );

    //

    logic lose_logic;

    // Part 1

    state_t state;
    direction_t direction;
    logic [$clog2(`tick)-1:0] ms_count;
    logic no_response;
    logic game_over;
    logic warning;
    state_machine sm_ins (
        .clock(controller_phase1),
        .reset_n(reset_n),
        .button_down(button_down),
        .snake(snake),
        .lose_logic(lose_logic),
        .state(state),
        .direction(direction),
        .ms_count(ms_count),
        .no_response(no_response),
        .game_over(game_over),
        .warning(warning)
    );

    // Part 2

    // handle lose_logic and head

    logic has_food;
    logic food_eaten;
    snake_modifier hm_ins (
        .clock(controller_phase2),
        .reset_n(reset_n),
        .state(state),
        .direction(direction),
        .ms_count(ms_count),
        .random_number_1(random_number_1),
        .random_number_2(random_number_2),
        .snake(snake),
        .food(food),
        .has_food(has_food),
        .food_eaten(food_eaten),
        .lose_logic(lose_logic)
    );

    // Part 3

    audio_output_generator aog_ins (
        .clock(controller_phase3),
        .reset_n(reset_n),
        .no_response(no_response),
        .game_over(game_over),
        .food_eating(food_eaten),
        .warning(warning),
        .frequency_select(frequency_select)
    );

    logic[14:0] startup_image_address;
    logic[7:0] startup_image_data;
    assign startup_image_address = (screen_point.y / 4) * (`screen_width / 4) + screen_point.x / 4;
    startup_image_rom sir_ins (
        .clka(clock),
        .addra(startup_image_address),
        .douta(startup_image_data)
    );

    const point_t snake_head_s = '{x: `snake_head_size, y: `snake_head_size};
    point_t snake_head_delta;
    assign snake_head_delta = point_add(point_sub(screen_point, snake.array[0]), snake_head_s);

    logic[9:0] head_image_address;

    always @(posedge lcd_screen_dclk) begin
        if ((snake_head_delta.y / 2) * (2 * `snake_head_size / 2) + (snake_head_delta.x / 2) < 1024)
            head_image_address <= (snake_head_delta.y / 2) * (2 * `snake_head_size / 2) + (snake_head_delta.x / 2);
        else
            head_image_address <= 0;
    end

    logic[7:0] head_image_normal_data;
    head_image_normal_rom hinr_ins (
        .clka(clock),
        .addra(head_image_address),
        .douta(head_image_normal_data)
    );

    logic[7:0] head_image_lose_data;
    head_image_lose_rom hilr_ins (
        .clka(clock),
        .addra(head_image_address),
        .douta(head_image_lose_data)
    );

    logic[7:0] head_image_happy_data;
    head_image_happy_rom hihr_ins (
        .clka(clock),
        .addra(head_image_address),
        .douta(head_image_happy_data)
    );

    const point_t food_s = '{x: `food_size, y: `food_size};
    point_t food_delta;
    assign food_delta = point_add(point_sub(screen_point, food), food_s);

    logic[9:0] food_image_address;

    always @(posedge lcd_screen_dclk) begin
        if ((food_delta.y / 2) * (2 * `food_size / 2) + (food_delta.x / 2) < 1024)
            food_image_address <= (food_delta.y / 2) * (2 * `food_size / 2) + (food_delta.x / 2);
        else
            food_image_address <= 0;
    end

    logic[7:0] food_image_normal_data;
    food_image_rom fir_ins (
        .clka(clock),
        .addra(food_image_address),
        .douta(food_image_normal_data)
    );

    int count;
    logic selcect_switch;
    always @(posedge lcd_screen_dclk or negedge reset_n) begin
        if (~ reset_n) begin
            selcect_switch <= 0;
            count <= 0;
        end else begin
            if (count == `horizontal_period * `vertical_period - 1) begin
                selcect_switch <= 1;
                count <= 0;
            end else begin
                selcect_switch <= 0;
                count <= count + 1;
            end
        end
    end

    localparam selcect_size = 32;
    int selcect_number[0 : selcect_size - 1];
    always @(posedge selcect_switch or negedge reset_n) begin
        if (~ reset_n)
            for (int i = 0; i < selcect_size; i++)
                selcect_number[i] = 1;
        else begin
            if (selcect_number[0] + selcect_size >= snake.length)
                selcect_number[0] = 1;
            else
                selcect_number[0] = selcect_number[0] + selcect_size;
            for (int i = 1; i < selcect_size; i++)
                if (selcect_number[i - 1] + 1 >= snake.length)
                    selcect_number[i] = 1;
                else
                    selcect_number[i] = selcect_number[i - 1] + 1;
        end
    end

    point_t body[0 : selcect_size - 1];

    always_comb begin
        for (int i = 0; i < selcect_size; i++)
            body[i] = snake.array[selcect_number[i]];
    end

    logic[0 : selcect_size - 1] in_body;

    always_comb begin
        for (int i = 0; i < selcect_size; i++)
            in_body[i] = in_circle(screen_point, body[i], `snake_body_size);
    end
    
    always @(posedge lcd_screen_dclk or negedge reset_n) begin
        if (~ reset_n)
            {screen_r, screen_g, screen_b} <= ~ 0;
        else
            if (state == initial_state)
                {screen_r, screen_g, screen_b} <= startup_image_data;
            else
                if (in_circle(screen_point, snake.array[0], `snake_head_size))
                    case (state)
                        pause_state: {screen_r, screen_g, screen_b} <= head_image_normal_data;
                        game_state: {screen_r, screen_g, screen_b} <= head_image_happy_data;
                        over_state: {screen_r, screen_g, screen_b} <= head_image_lose_data;
                    endcase
                else if (has_food && in_circle(screen_point, food, `food_size))
                    {screen_r, screen_g, screen_b} <= food_image_normal_data;
                else if ( snake.length > 1 && (| in_body))
                    {screen_r, screen_g, screen_b} <= {3'b000, 2'b11, 3'b000};
                else
                    {screen_r, screen_g, screen_b} <= {3'b000, 2'b00, 3'b000};
    end

endmodule
