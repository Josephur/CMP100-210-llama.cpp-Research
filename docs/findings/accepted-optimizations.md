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

See [Measurement Summary](measurement-summary.md) for the public-safe rows and
their evidence scope.
