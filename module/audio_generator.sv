`include "config.svh"

parameter audio_generator_frequency = 100000000;
parameter note_number = 36;

parameter int note_frequency_array [0 : note_number - 1] = {
    262,   //FREQUENCY_C4
    277,   //FREQUENCY_Cs4
    294,   //FREQUENCY_D4
    311,   //FREQUENCY_Ds4
    330,   //FREQUENCY_E4
    349,   //FREQUENCY_F4
    370,   //FREQUENCY_Fs4
    392,   //FREQUENCY_G4
    415,   //FREQUENCY_Gs4
    440,   //FREQUENCY_A4
    466,   //FREQUENCY_As4
    494,   //FREQUENCY_B4
    523,   //FREQUENCY_C5
    554,   //FREQUENCY_Cs5
    587,   //FREQUENCY_D5
    622,   //FREQUENCY_Ds5
    659,   //FREQUENCY_E5
    698,   //FREQUENCY_F5
    740,   //FREQUENCY_Fs5
    784,   //FREQUENCY_G5
    831,   //FREQUENCY_Gs5
    880,   //FREQUENCY_A5
    932,   //FREQUENCY_As5
    988,   //FREQUENCY_B5
    1046,  //FREQUENCY_C6
    1109,  //FREQUENCY_Cs6
    1175,  //FREQUENCY_D6
    1245,  //FREQUENCY_Ds6
    1318,  //FREQUENCY_E6
    1397,  //FREQUENCY_F6
    1480,  //FREQUENCY_Fs6
    1568,  //FREQUENCY_G6
    1661,  //FREQUENCY_Gs6
    1760,  //FREQUENCY_A6
    1865,  //FREQUENCY_As6
    1976   //FREQUENCY_B6
};

module audio_generator (
    input logic clock,
    input logic reset_n,
    input logic [31:0] frequency_select,
    output logic audio_output
);

    logic [31:0] note_divisor[0 : note_number - 1];

    always_comb
        for (int i = 0; i < note_number; i++)
            note_divisor[i] = audio_generator_frequency / note_frequency_array[i];

    logic [31:0] index;
    assign index = (& frequency_select) ? 0 : frequency_select;

    logic audio_signal;

    v_divider #(32) vdiv_ins (
        .clock(clock),
        .reset_n(reset_n),
        .divisor(note_divisor[index]),
        .clock_out(audio_signal)
    );

    assign audio_output = (& frequency_select) ? 0 : audio_signal;

endmodule
