`include "config.svh"

module display_data_generator (
    input logic clock,
    input logic reset_n,
    input state_t state,
    input logic [1:0] h_ptr,
    input logic [2:0] v_ptr,
    input int jar_number,
    input int one_number,
    input int now_count,
    input int now_jar_count,
    input int total_pill,

    output logic [7:0][5:0] display_code,
    output logic [7:0] display_dp
);

    assign display_dp = 0;

    logic flip;
    divider #(10000000) flip_ins (
        .clock(clock),
        .reset_n(reset_n),
        .clock_out(flip)
    );

    always_ff @(posedge clock or negedge reset_n) begin
        if (~ reset_n)
            display_code <= ~ 0;
        else begin
            display_code = ~ 0;
            case (state)
                setting_state:
                    case (v_ptr[0])
                        0: begin
                            display_code[7] = 6'b010011; // J
                            display_code[6] = 6'b001010; // A
                            display_code[5] = 6'b011011; // R

                            display_code[3] = jar_number / 1000;
                            display_code[2] = jar_number / 100 % 10;
                            display_code[1] = jar_number / 10 % 10;
                            display_code[0] = jar_number / 1 % 10;
                            if (flip)
                                display_code[h_ptr] = ~ 0;
                        end
                        1: begin
                            display_code[7] = 6'b011000; // O
                            display_code[6] = 6'b010111; // N
                            display_code[5] = 6'b001110; // E

                            display_code[3] = one_number / 1000;
                            display_code[2] = one_number / 100 % 10;
                            display_code[1] = one_number / 10 % 10;
                            display_code[0] = one_number / 1 % 10;
                            if (flip)
                                display_code[h_ptr] = ~ 0;
                        end
                    endcase
                error_state:
                    display_code = ~ 0; // do nothing;
                default:
                    case (v_ptr)
                        0: begin
                            display_code[7] = total_pill / 10000000 % 10;
                            display_code[6] = total_pill / 1000000 % 10;
                            display_code[5] = total_pill / 100000 % 10;
                            display_code[4] = total_pill / 10000 % 10;
                            display_code[3] = total_pill / 1000 % 10;
                            display_code[2] = total_pill / 100 % 10;
                            display_code[1] = total_pill / 10 % 10;
                            display_code[0] = total_pill / 1 % 10;
                        end
                        1: begin
                            display_code[7] = 6'b011001; // P

                            display_code[3] = now_count / 1000 % 10;
                            display_code[2] = now_count / 100 % 10;
                            display_code[1] = now_count / 10 % 10;
                            display_code[0] = now_count / 1 % 10;
                        end
                        2: begin
                            display_code[7] = 6'b010111; // N
                            display_code[6] = 6'b011000; // O

                            display_code[3] = now_jar_count / 1000 % 10;
                            display_code[2] = now_jar_count / 100 % 10;
                            display_code[1] = now_jar_count / 10 % 10;
                            display_code[0] = now_jar_count / 1 % 10;
                        end
                        3: begin
                            display_code[7] = 6'b010011; // J
                            display_code[6] = 6'b001010; // A
                            display_code[5] = 6'b011011; // R

                            display_code[3] = jar_number / 1000;
                            display_code[2] = jar_number / 100 % 10;
                            display_code[1] = jar_number / 10 % 10;
                            display_code[0] = jar_number / 1 % 10;
                        end
                        4: begin
                            display_code[7] = 6'b011000; // O
                            display_code[6] = 6'b010111; // N
                            display_code[5] = 6'b001110; // E

                            display_code[3] = one_number / 1000;
                            display_code[2] = one_number / 100 % 10;
                            display_code[1] = one_number / 10 % 10;
                            display_code[0] = one_number / 1 % 10;
                        end
                    endcase
            endcase
        end
    end

endmodule
