// Since our implementation has cascaded combinatorial logic, verilator gets
// upset about the fact that it has to iterate to resolve the full computation
// chain. We can silence the warning with this lint_off flag.
/* verilator lint_off UNOPTFLAT */
module adder_4b(
    // Input clock. At the positive edge of this clock, we will update the
    // value of our output data register.
    input wire i_clk,
    // Input 4-bit words to add
    input wire [3:0] in_a,
    input wire [3:0] in_b,
    // Output data buffer containing the result of the addition
    output reg [3:0] out_sum,
    // Single output bit indicating if the addition overflowed
    output reg out_overflow
);

// Define two internal wires. We need these to connect the full adder
// elements together as a bus that we can then load into our output buffer.
wire [3:0] full_adder_sum;
wire [3:0] full_adder_carry_outs;

// We now need 4 full adders, with the carry out of each one fed into
// the carry in of the next.
// We could write out all of these by hand, but there exists a verilog
// keyword 'generate', which makes repeated declaration of elements like
// this a lot simpler.

// Because our first adder is special, we need to keep it outside the loop
full_adder adder_0(
    // Take the 0'th bit of the input words as operands
    in_a[0], in_b[0],
    // Since this is the first bit, the carry-in can be hard-coded as 0.
    1'b0,
    // The output signals can be connected into the bus we made above so
    // that they can be used by the next adder
    full_adder_sum[0],
    full_adder_carry_outs[0]
);

// Now we can generate the rest of the adders.
// First, we need to define a loop variable for the generate, like
// we would in any programming language
genvar i;
// Counting from 1 to the total number of bits in the operands, generate
// a new full adder that operates on that bit of the input words, plus
// the carry of the prevoius adder.
generate
// We use the function $bits to get the width of our in_a parameter, so
// that if it changes we don't need to modify this code.
for (i = 1; i < $bits(in_a); i++)
    full_adder adder(
        // Add the i'th bit of both operands
        in_a[i],
        in_b[i],
        // Use the carry-in from the previous adder
        full_adder_carry_outs[i-1],
        // Connect our sum output to the full adder bus
        full_adder_sum[i],
        // Likewise connect our carry out so that it can be used by
        // the next full adder
        full_adder_carry_outs[i]
    );
endgenerate

// Now we can set up the sequential logic part of this adder.
// For clock or other event-driven signals, we need a sensitivity
// selector. Whenever the conditions in parenthesis are met, the
// body of the block will execute.
always @(posedge i_clk) begin
    // At the positive clock edge, we want to take the current value
    // that is being calculated using combinatorial logic by the full
    // adder, and copy that data into our output data buffer.
    // For this, we use the non-blocking assignment operator, <=
    out_sum <= full_adder_sum;
    // Similarly, we take the final carry bit of the adder and use
    // that as our overflow indicator.
    out_overflow <= full_adder_carry_outs[$bits(in_a)-1];
end

endmodule
