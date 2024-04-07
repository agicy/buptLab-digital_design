module segment_decoder (
    input  logic [5:0] data,
    output logic [6:0] segment_n
);
    always_comb begin
        case (data)
            6'b000000: segment_n = 7'b0000001;  // 0
            6'b000001: segment_n = 7'b1001111;  // 1
            6'b000010: segment_n = 7'b0010010;  // 2
            6'b000011: segment_n = 7'b0000110;  // 3
            6'b000100: segment_n = 7'b1001100;  // 4
            6'b000101: segment_n = 7'b0100100;  // 5
            6'b000110: segment_n = 7'b0100000;  // 6
            6'b000111: segment_n = 7'b0001111;  // 7
            6'b001000: segment_n = 7'b0000000;  // 8
            6'b001001: segment_n = 7'b0000100;  // 9
            6'b001010: segment_n = 7'b0001000;  // a
            6'b001011: segment_n = 7'b1100000;  // b
            6'b001100: segment_n = 7'b0110001;  // c
            6'b001101: segment_n = 7'b1000010;  // d
            6'b001110: segment_n = 7'b0110000;  // e
            6'b001111: segment_n = 7'b0111000;  // f
            6'b010000: segment_n = 7'b0100001;  // g
            6'b010001: segment_n = 7'b1001000;  // h
            6'b010010: segment_n = 7'b1111011;  // i
            6'b010011: segment_n = 7'b1000111;  // j
            6'b010100: segment_n = 7'b1010000;  // k
            6'b010101: segment_n = 7'b1110001;  // l
            6'b010110: segment_n = 7'b0101010;  // m
            6'b010111: segment_n = 7'b1101010;  // n
            6'b011000: segment_n = 7'b1100010;  // o
            6'b011001: segment_n = 7'b0011000;  // p
            6'b011010: segment_n = 7'b0001100;  // q
            6'b011011: segment_n = 7'b1111010;  // r
            6'b011100: segment_n = 7'b0101100;  // s
            6'b011101: segment_n = 7'b1110000;  // t
            6'b011110: segment_n = 7'b1000001;  // u
            6'b011111: segment_n = 7'b1100011;  // v
            6'b100000: segment_n = 7'b1010100;  // w
            6'b100001: segment_n = 7'b1101100;  // x
            6'b100010: segment_n = 7'b1000100;  // y
            6'b100011: segment_n = 7'b1010010;  // z
            default:   segment_n = 7'b1111111;
        endcase
    end
endmodule
