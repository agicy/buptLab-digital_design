`include "config.svh"

module input_receiver (
    input logic clock,
    input logic reset_n,
    input logic [4:0] button,
    output logic [4:0] button_down
);

    logic [4:0] last_button;
    always @(posedge clock or negedge reset_n) begin
        if (~reset_n) begin
            button_down <= 'b0;
            last_button <= 'b0;
        end else begin
            button_down = (~last_button) & button;
            last_button = button;
        end
    end

endmodule
