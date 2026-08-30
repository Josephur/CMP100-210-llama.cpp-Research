# Public llama.cpp patch series

This series contains the ten complete source hunks retained directly by the
public audit plus two clean semantic reconstructions of accepted mechanisms
whose original candidate hunks were interleaved with rejected experiments.
The patches are ordered and independently auditable against the pinned upstream
base. They do not contain binaries, model data, raw benchmark evidence,
deployment configuration, or repository history.

| Patch | Changed files | Mechanism | Evidence | Integrity | Scope |
| --- | --- | --- | --- | --- | --- |
| [`0001-force-dp4a-mmq-routing.patch`](patches/llama.cpp/0001-force-dp4a-mmq-routing.patch) | `common/arg.cpp`<br>`ggml/src/ggml-cuda/mmq.cu`<br>`tests/test-arg-parser.cpp` | Forced DP4A/MMQ routing | [Accepted optimization](docs/findings/accepted-optimizations.md#forced-dp4ammq-for-tested-quantized-prefill) | Exact deterministic output retained | Runtime selection and focused argument-parser coverage; eight audited hunks |
| [`0002-route-volta-q4k-q5k-mmq.patch`](patches/llama.cpp/0002-route-volta-q4k-q5k-mmq.patch) | `ggml/src/ggml-cuda/mmq.cuh` | Volta Q4_K/Q5_K MMQ configuration routing | [Accepted optimization](docs/findings/accepted-optimizations.md#forced-dp4ammq-for-tested-quantized-prefill) | Exact deterministic output retained | SM70 Q4_K/Q5_K configuration selection only; two audited hunks |
| [`0003-parallel-model-loader.patch`](patches/llama.cpp/0003-parallel-model-loader.patch) | `src/llama-mmap.cpp`/`.h`<br>`src/llama-model-loader.cpp`/`.h`<br>`src/llama-model.cpp`<br>`tests/CMakeLists.txt`<br>`tests/test-llama-file-read-at.cpp` | Parallel model loading | [Accepted optimization](docs/findings/accepted-optimizations.md#parallel-loading) | Exact deterministic output retained | Default-off `LLAMA_MODEL_LOAD_PARALLEL=1`; positional reads, host-first ordering, concurrent GPU uploads, synchronized progress and finalization; rejected read-ahead and trace experiments omitted |
| [`0004-lossless-mapped-host-bridge.patch`](patches/llama.cpp/0004-lossless-mapped-host-bridge.patch) | `ggml/src/ggml-backend.cpp`<br>`ggml/src/ggml-cuda/common.cuh`<br>`ggml/src/ggml-cuda/ggml-cuda.cu` | Lossless boundary transport and pinned staging | [Accepted optimization](docs/findings/accepted-optimizations.md#lossless-boundary-transport-and-pinned-staging) | Exact deterministic output retained | Default-off `GGML_CUDA_MAPPED_HOST_BRIDGE=1`; scheduler-visible CUDA ownership and four mapped pinned staging slots for no-P2P boundaries up to 64 MiB; lossy FP16 and superseded event/prefill pipelines omitted |

The original compound candidate still accounts for 586 hunks: ten retained and
576 excluded. Its 70 loader-related and 233 transport-related mixed hunks remain
excluded rather than being falsely relabeled as retained. Patches 0003 and 0004
are narrow source-level reconstructions against the pinned base. See the
machine-readable [`audit.json`](patches/llama.cpp/audit.json) for the complete
retained/excluded accounting and reconstruction disposition.

Application and source-build boundaries are documented in the
[source release guide](docs/source-release.md).
