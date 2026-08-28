# Methodology

## Experimental boundary

Each published record is a configuration-specific observation. A matched A/B
holds the binary, model and quantization, request, selected-card topology,
layer split, and clock policy constant. The selected CMP cards are verified at
1,380 MHz before and during comparison work; idle clock behavior is not used as
a performance baseline.

The normal progression is a deterministic 32K test followed by a 100K test
only when the smaller gate is correct and safe. A run must complete its exact
output comparison before its speed can be considered. Retrieval markers, HTTP
success, and token count are supporting checks, not a substitute for identical
deterministic output.

## Measurements

For each comparable request, the decision record considers:

- time to first token, prompt throughput, decode throughput, and complete wall
  time;
- PCIe receive/transmit traffic normalized per request or token where useful;
- server-process CPU user/system time, core-seconds, context switches, faults,
  and process I/O rather than only whole-host utilization;
- selected-card clocks, GPU utilization, temperature, VRAM, and energy or
  active time when supported; and
- host memory, pinned allocations, and internal activation/fallback/wait
  counters that explain the mechanism.

Low GPU utilization or a smaller PCIe peak is not automatically better. A
candidate must show the same work completed with a favorable end-to-end or
normalized-resource result. Likewise, a large microbenchmark improvement does
not earn promotion without a corresponding complete-request result.

## Evidence vocabulary

- **Accepted** means the stated configuration passed its integrity and physical
  gate and was retained for that tested stack.
- **Rejected** means an integrity, safety, repeatability, or end-to-end gate
  failed. Rejected results remain useful evidence, not failed attempts to hide.
- **Configuration-specific** means the result must not be generalized to a
  different model, quantization, device topology, or newer upstream revision
  without a new matched test.
