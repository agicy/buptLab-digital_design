`ifndef _GLOBAL_CONFIGURATION_H_
`define _GLOBAL_CONFIGURATION_H_

function shortint abs (input shortint x);
    if (x >= 0)
        return x;
    else
        return - x;
endfunction

function int sqr (input shortint x);
    return x * x;
endfunction

typedef enum logic [1:0] {
    initial_state,
    pause_state,
    game_state,
    over_state
} state_t;

typedef enum logic [2:0] {
    none,
    up,
    down,
    left,
    right
} direction_t;

`define screen_width 800
`define screen_height 480
`define horizontal_period 928
`define horizontal_valid_count 800
`define vertical_period 525
`define vertical_valid_count 480

typedef struct packed {
    shortint x;
    shortint y;
} point_t;

function point_t point_add (input point_t a, input point_t b);
    shortint sum_x, sum_y;
    sum_x = a.x + b.x;
    sum_y = a.y + b.y;
    if (sum_x >= `screen_width)
        sum_x = sum_x - `screen_width;
    if (sum_y >= `screen_height)
        sum_y = sum_y - `screen_height;
    return '{x: sum_x, y: sum_y};
endfunction

function point_t point_sub (input point_t a, input point_t b);
    shortint sum_x, sum_y;
    sum_x = a.x - b.x;
    sum_y = a.y - b.y;
    if (sum_x < 0)
        sum_x = sum_x + `screen_width;
    if (sum_y < 0)
        sum_y = sum_y + `screen_height;
    return '{x: sum_x, y: sum_y};
endfunction

function int get_distance (input point_t a, input point_t b);
    shortint delta_x, delta_y;
    delta_x = abs(a.x - b.x);
    delta_y = abs(a.y - b.y);
    if (delta_x > `screen_width / 2)
        delta_x = `screen_width - delta_x;
    if (delta_y > `screen_height / 2)
        delta_y = `screen_height - delta_y;
    return sqr(delta_x) + sqr(delta_y);
endfunction

function bit in_circle (input point_t x, input point_t o, input shortint radius);
    return get_distance(x, o) <= sqr(radius);
endfunction

function bit circle_intersect (input point_t o1, input shortint radius1, input point_t o2, input shortint radius2);
    return get_distance(o1, o2) <= sqr(radius1 + radius2);
endfunction

`define frequency 100000000
`define snake_head_size 32
`define snake_body_size 32
`define food_size 32
`define tick 3200000
`define audio_bps 4
`define max_length 64
`define delta_step 10
`define step_length (`snake_body_size + `delta_step)

typedef struct {
    logic [31:0] length;
    point_t array[0 : `max_length - 1];
} snake_t;

function point_t step_up (input point_t p);
    const static point_t vertical_step = '{x: 0, y: `step_length};
    return point_add(p, vertical_step);
endfunction

function point_t step_down (input point_t p);
    const static point_t vertical_step = '{x: 0, y: `step_length};
    return point_sub(p, vertical_step);
endfunction

function point_t step_left (input point_t p);
    const static point_t horizontal_step = '{x: `step_length, y: 0};
    return point_sub(p, horizontal_step);
endfunction

function point_t step_right (input point_t p);
    const static point_t horizontal_step = '{x: `step_length, y: 0};
    return point_add(p, horizontal_step);
endfunction

function logic food_eating (input point_t food, input snake_t snake);
    return circle_intersect(food, `food_size, snake.array[0], `snake_head_size);
endfunction

`endif
