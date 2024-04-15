`include "config.svh"

parameter buttons_frequency = 100000000;
parameter buttons_debounce_ms = 10;
parameter buttons_number = 5;

module buttons (
    input logic clock,
    input logic reset_n,
    input logic [buttons_number - 1 : 0] raw_button,
    output logic [buttons_number - 1 : 0] button
);

    logic [buttons_number - 1 : 0] sync_button;
    synchronizer #(
        .width(buttons_number)
    ) sync_ins (
        .clock(clock),
        .reset_n(reset_n),
        .in(raw_button),
        .out(sync_button)
    );

    generate
        for (genvar i = 0; i < buttons_number; i++) begin : debouncer_gen
            debouncer #(
                .frequency(buttons_frequency),
                .modulus  (buttons_frequency / (1000 / buttons_debounce_ms))
            ) deb_ins (
                .clock(clock),
                .reset_n(reset_n),
                .in(sync_button[i]),
                .out(button[i])
            );
        end
    endgenerate

endmodule
