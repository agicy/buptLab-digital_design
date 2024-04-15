parameter keyboards_frequency = 2500000;
parameter keyboards_debounce_ms = 10;

module keyboards (
    input logic clock,
    input logic reset_n,
    input logic [3:0] keyboard_row_n,
    output logic [3:0] keyboard_col_n,
    output logic [15:0] keyboard
);

    logic clock_keyboards;
    divider #(100000000 / keyboards_frequency) k_div_ins (
        .clock(clock),
        .reset_n(reset_n),
        .clock_out(clock_keyboards)
    );

    logic [3:0] column_scanning;
    logic [3:0][3:0] inner_keyboard;
    always_ff @(posedge clock_keyboards or negedge reset_n) begin
        if (~ reset_n) begin
            column_scanning <= 0;
            inner_keyboard <= 0;
        end else
            case (column_scanning)
                4'b1110: begin
                    for (int i = 0; i < 4; i++)
                        inner_keyboard[i][0] <= ~ keyboard_row_n[i];
                    column_scanning <= 4'b1101;
                end
                4'b1101: begin
                    for (int i = 0; i < 4; i++)
                        inner_keyboard[i][1] <= ~ keyboard_row_n[i];
                    column_scanning <= 4'b1011;
                end
                4'b1011: begin
                    for (int i = 0; i < 4; i++)
                        inner_keyboard[i][2] <= ~ keyboard_row_n[i];
                    column_scanning <= 4'b0111;
                end
                4'b0111: begin
                    for (int i = 0; i < 4; i++)
                        inner_keyboard[i][3] <= ~ keyboard_row_n[i];
                    column_scanning <= 4'b1110;
                end
                default: column_scanning <= 4'b1110;
            endcase
    end

    assign keyboard_col_n = column_scanning;

    logic [3:0][3:0] debounced_keyboard;

    generate;
        for (genvar i = 0; i < 4; i++)
            for (genvar j = 0; j < 4; j++) begin : debouncer_gen
                debouncer #(
                    .frequency(keyboards_frequency),
                    .modulus(keyboards_frequency / (1000 / keyboards_debounce_ms))
                ) deb_ins (
                    .clock(clock),
                    .reset_n(reset_n),
                    .in(inner_keyboard[i][j]),
                    .out(debounced_keyboard[i][j])
                );
            end
    endgenerate

    assign keyboard = debounced_keyboard;

endmodule
