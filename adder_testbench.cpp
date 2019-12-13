#include <stdlib.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include <Vadder_4b.h>
#include <Vfull_adder.h>

int main(int argc, char **argv) {
  // Initialize Verilators variables
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);

  // Create our trace output
  VerilatedVcdC *vcd_trace = new VerilatedVcdC();

  // Create an instance of our module under test, in this case the 4-bit adder
  Vadder_4b *adder = new Vadder_4b();

  // Trace all of the adder signals for the duration of the run
  adder->trace(vcd_trace, 99);

  // Output the trace file
  vcd_trace->open("adder_testbench.vcd");

  // We need to keep track of what the time is for the trace file.
  // We will increment this every time we toggle the clock
  uint64_t trace_tick = 0;

  // For each possible 4-bit input a
  for (unsigned in_a = 0; in_a < (1 << 4); in_a++) {
    // For each possible 4-bit input b
    for (unsigned in_b = 0; in_b < (1 << 4); in_b++) {
      // Negative edge of the clock
      adder->i_clk = 0;
      // During the low clock period, set the input data for the adder
      adder->in_a = in_a;
      adder->in_b = in_b;
      // Evaluate any changes triggered by the falling edge
      // This includes the combinatorial logic in our design
      adder->eval();
      // Dump the current state of all signals to the trace file
      vcd_trace->dump(trace_tick++);

      // Positive edge of the clock
      adder->i_clk = 1;
      // Evaluate any changes triggered by the falling edge
      adder->eval();
      // Dump the current state of all signals to the trace file
      vcd_trace->dump(trace_tick++);

      // The adder should now have updated to show the new data on the output
      // buffer. Assert that the value and the overflow flag are correct.
      const unsigned expected = in_a + in_b;
      const unsigned expected_4bit = expected & 0b1111;
      const bool expected_carry = expected > 0b1111;
      // Check the sum is correct
      if (adder->out_sum != expected_4bit) {
        fprintf(stderr, "Bad result: %u + %u should be %u, got %u\n", in_a,
                in_b, expected, adder->out_sum);
        exit(EXIT_FAILURE);
      }
      // Check the carry is correct
      if (expected_carry != adder->out_overflow) {
        fprintf(stderr,
                "Bad result: %u + %u should set carry flag to %u, got %u\n",
                in_a, in_b, expected_carry, adder->out_overflow);
        exit(EXIT_FAILURE);
      }
    }
  }

  // Flush the trace data
  vcd_trace->flush();
  // Close the trace
  vcd_trace->close();
  // Testbench complete
  exit(EXIT_SUCCESS);
}
