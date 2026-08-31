# Rejected Ideas

Negative results are retained because they narrow the next credible hypothesis.
None of these results should be generalized beyond its recorded configuration.

## Mapped-host FP16 transport

Compressing eligible mapped-host boundary activations to FP16 cut crossing
traffic in the tested path, and a matched run showed a small prompt-throughput
improvement. It was rejected because the deterministic response changed.
The project treats output identity as the production gate; a marginal speed or
traffic reduction does not override it.

## Elaborate SM70 attention kernels

An isolated attention candidate looked faster, but its generated code consumed
too many registers and reduced occupancy. It did not clear the resource gate
for complete-request testing. On this SM70 target, a source-level instruction
reduction is not evidence of a gain until SASS resources and physical timing
agree.

## Expert-loop microkernel improvements without request ownership

A grouped MoE operation became substantially faster in isolation, yet matched
complete requests changed by only a few hundredths of a percent. The operation
was not a material owner of end-to-end wall time on the tested stack. Further
work must first prove a larger complete-request owner.

## Microbatch changes without output proof

Several microbatch choices completed and appeared faster while changing the
retained deterministic response. They remain rejected under the integrity
policy even where a marker check or token count succeeded.

## Exact D256 attention kernel without request ownership

A three-CTA whole-tile D256 attention candidate kept deterministic output and
made the isolated production-shaped operation about 24% faster. In the matched
long-context complete request, prompt throughput moved only +0.527% and wall
time only -0.492%. It is shelved rather than promoted: a fast sub-operation is
not a user-visible gain when the surrounding request still owns nearly all of
the elapsed time.
