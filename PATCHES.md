# Public llama.cpp patch series

This series contains the seven accepted mechanisms retained for the tested
configuration, ordered and independently auditable against the pinned upstream
base `25b03bd5b987e4e8b11691c42afc3f317a9d1515`. Applying all seven to that base reproduces the exact source
tree behind the project's current deployed build, verified byte for byte. They do not contain binaries, model data, raw benchmark evidence,
deployment configuration, or repository history.

| Patch | Changed files | Mechanism | Evidence | Integrity | Scope |
| --- | --- | --- | --- | --- | --- |
| [`0001-force-dp4a-mmq-routing.patch`](patches/llama.cpp/0001-force-dp4a-mmq-routing.patch) | `common/arg.cpp`<br>`ggml/src/ggml-cuda/mmq.cu`<br>`tests/test-arg-parser.cpp` | Forced DP4A/MMQ routing | [Accepted optimization](docs/findings/accepted-optimizations.md#forced-dp4ammq-for-tested-quantized-prefill) | Exact deterministic output retained | Runtime selection and focused argument-parser coverage; eight audited hunks |
| [`0002-route-volta-q4k-q5k-mmq.patch`](patches/llama.cpp/0002-route-volta-q4k-q5k-mmq.patch) | `ggml/src/ggml-cuda/mmq.cuh` | Volta Q4_K/Q5_K MMQ configuration routing | [Accepted optimization](docs/findings/accepted-optimizations.md#forced-dp4ammq-for-tested-quantized-prefill) | Exact deterministic output retained | SM70 Q4_K/Q5_K configuration selection only; two audited hunks |
| [`0003-parallel-model-loader.patch`](patches/llama.cpp/0003-parallel-model-loader.patch) | `src/llama-mmap.cpp`/`.h`<br>`src/llama-model-loader.cpp`/`.h`<br>`src/llama-model.cpp`<br>`tests/CMakeLists.txt`<br>`tests/test-llama-file-read-at.cpp` | Parallel model loading | [Accepted optimization](docs/findings/accepted-optimizations.md#parallel-loading) | Exact deterministic output retained | Default-off `LLAMA_MODEL_LOAD_PARALLEL=1`; positional reads, concurrent GPU uploads, synchronized progress and finalization; rejected read-ahead and tracing experiments omitted |
| [`0004-lossless-mapped-host-bridge.patch`](patches/llama.cpp/0004-lossless-mapped-host-bridge.patch) | `ggml/src/ggml-backend.cpp`<br>`ggml/src/ggml-cuda/common.cuh`<br>`ggml/src/ggml-cuda/ggml-cuda.cu` | Lossless boundary transport and pinned staging | [Accepted optimization](docs/findings/accepted-optimizations.md#lossless-boundary-transport-and-pinned-staging) | Exact deterministic output retained | Default-off `GGML_CUDA_MAPPED_HOST_BRIDGE=1`; scheduler-visible CUDA ownership and four mapped pinned staging slots for no-P2P boundaries up to 64 MiB; lossy FP16 and superseded pipelines omitted |

| [`0005-research-selector-registry.patch`](patches/llama.cpp/0005-research-selector-registry.patch) | `ggml/include/ggml-research.h`<br>`ggml/src/ggml-research.cpp`<br>`ggml/src/CMakeLists.txt`<br>`ggml/src/ggml-cuda/mmq.cu`<br>`src/llama-model-loader.cpp`/`.h`<br>`src/llama-model.cpp`<br>`tools/server/*` | Runtime research selectors and activation reporting | [Accepted optimization](docs/findings/accepted-optimizations.md#runtime-research-selectors) | Exact deterministic output retained | Additive registry recording every selector read, so a set-but-unread selector is detectable; no behavior change on its own |
| [`0006-prompt-graph-capture-seed.patch`](patches/llama.cpp/0006-prompt-graph-capture-seed.patch) | `ggml/src/ggml-cuda/common.cuh`<br>`ggml/src/ggml-cuda/ggml-cuda.cu` | Capture-only prompt graph seed | [Accepted optimization](docs/findings/accepted-optimizations.md#capture-only-prompt-graph-seed) | Exact deterministic output retained | Default-off `GGML_CUDA_PROMPT_GRAPH_CAPTURE_SEED=1`; first observation of a graph identity is captured but never replayed; prompt namespace separate from decode and released at first batch-one decode graph |
| [`0007-device-side-mask-expansion.patch`](patches/llama.cpp/0007-device-side-mask-expansion.patch) | `ggml/include/ggml-backend.h`<br>`ggml/src/ggml-backend.cpp`<br>`src/llama-input-mask-hint.h`<br>`src/llama-kv-cache.cpp`<br>`src/llama-memory-hybrid-idx.cpp` | Device-side attention mask expansion | [Accepted optimization](docs/findings/accepted-optimizations.md#device-side-attention-mask-expansion) | Exact deterministic output retained | Default-off `GGML_SCHED_DEVICE_MASK=1`; causal and sparse-attention masks reconstructed on the destination GPU from compact row hints |
The series was re-pinned from the earlier base `0d0bfcd4` to `25b03bd5b`, the
upstream revision the project now builds on, because patches 0005 to 0007 exist
only against that newer base. Patches 0001 to 0004 carry the same accepted
mechanisms as the previous release and were regenerated from the project's own
commits rather than rewritten.

Rejected, output-changing, superseded and neutral experiments remain excluded.
In particular the mapped-host prefill pipeline, the pinned snapshot ring and the
event-ordered small upload are **not** included: they conflict with patch 0006,
because both record and replay the same prompt graphs, and the combination does
not preserve deterministic output.

The machine-readable [`audit.json`](patches/llama.cpp/audit.json) records the
original retained and excluded hunk accounting from the earlier `0d0bfcd4`
audit and has not been regenerated for the new base.

Application and source-build boundaries are documented in the
[source release guide](docs/source-release.md).
