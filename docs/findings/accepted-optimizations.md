# Accepted Optimizations

Accepted means retained for the explicitly tested configuration, not a general
claim about every GGUF, Volta device, model family, or llama.cpp revision.

## Forced DP4A/MMQ for tested quantized prefill

For the tested Qwen3.5 quantized prefill shapes, the generic FP16 Tensor
Core/cuBLAS route was not the best CMP100-210 path. Forcing llama.cpp's DP4A
MMQ route produced the strongest retained arithmetic result in the project.
One six-card 122B test family measured 2.36x prefill throughput at 128K versus
its matched automatic policy. Batch-one decode follows different MMVQ behavior,
so that prefill result is not represented as a decode gain.

## Lossless boundary transport and pinned staging

The retained transport work reduces avoidable host-owned staging and makes
buffer reuse explicit at multi-card boundaries. It is lossless: accepted runs
must retain identical deterministic output. This is valuable because the
configuration uses host staging across Gen1 x1 links and has no P2P/NVLink
path.

## Parallel loading

Model-load work retained concurrent card initialization and loading where the
runtime can do so safely. It improves readiness behavior, but model load is
reported separately from inference and is not counted as a token-generation
gain.

## Runtime research selectors

Feature switches in this research fork are read through a small additive
registry rather than raw `getenv`. The registry records every selector read, so
a selector that a deployment sets but that no surviving code reads becomes
detectable instead of silent. This matters after an upstream re-base: an
environment variable whose implementation was dropped is invisible otherwise,
and same-package A/B testing cannot see code that is missing from both arms.

## Capture-only prompt graph seed

On the tested configuration the prompt path submitted every compatible graph
directly from a single host thread, and prior attribution placed the large
majority of sampled server CPU cycles inside the driver submission path. This
mechanism captures and instantiates a graph executable on the first observation
of a prompt graph identity but deliberately does not launch it; the first
observation still executes through the normal direct path, and only later
observations replay. Prompt graphs use a namespace separate from decode graphs
and are released at the first batch-one decode graph. The measured effect is
strongly configuration-dependent: one tested model family gained a large
multiple of its prompt throughput while another gained a few percent, and one
showed a small batch-one decode cost. It is not represented as a decode gain.

## Device-side attention mask expansion

Attention masks are reconstructed on the destination GPU from compact row
hints instead of being uploaded in expanded form, which removes the upload
rather than compressing it and also covers the sparse-attention block bias.
This is valuable specifically because the configuration crosses Gen1 x1 links
with no P2P path, so avoided host-to-device bytes are worth more than they
would be on a normal fabric.

See [Measurement Summary](measurement-summary.md) for the public-safe rows and
their evidence scope.
