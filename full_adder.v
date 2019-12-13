// A full-adder circuit with combinatorial logic
module full_adder(
    input wire in_a,
    input wire in_b,
    input wire in_carry,
    output wire out_sum,
    output wire out_carry
);

// The truth table for a fill adder is like so:
// A B Cin | Sum Cout
// 0 0  0  |  0   0
// 1 0  0  |  1   0
// 0 1  0  |  1   0
// 1 1  0  |  0   1
// 0 0  1  |  1   0
// 1 0  1  |  0   1
// 0 1  1  |  0   1
// 1 1  1  |  1   1

// The sum is the XOR of all three input signals
assign out_sum = in_a ^ in_b ^ in_carry;

// The carry bit is set if either
// - Both A and B are set
// - The Carry in is set and either A or B is set
assign out_carry = (in_a & in_b) | (in_carry & (in_a ^ in_b));

endmodule
