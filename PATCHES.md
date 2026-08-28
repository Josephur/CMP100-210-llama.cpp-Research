# Public llama.cpp patch series

This series contains only the ten complete source hunks retained by the public
audit. The patches are ordered, independently preflighted against the pinned
upstream base, and scoped to two mechanisms. They do not contain binaries,
model data, raw benchmark evidence, deployment configuration, or repository
history.

| Patch | Changed files | Mechanism | Evidence | Integrity | Scope |
| --- | --- | --- | --- | --- | --- |
| [`0001-force-dp4a-mmq-routing.patch`](patches/llama.cpp/0001-force-dp4a-mmq-routing.patch) | `common/arg.cpp`<br>`ggml/src/ggml-cuda/mmq.cu`<br>`tests/test-arg-parser.cpp` | Forced DP4A/MMQ routing | [Accepted optimization](docs/findings/accepted-optimizations.md#forced-dp4ammq-for-tested-quantized-prefill) | Exact deterministic output retained | Runtime selection and focused argument-parser coverage; eight audited hunks |
| [`0002-route-volta-q4k-q5k-mmq.patch`](patches/llama.cpp/0002-route-volta-q4k-q5k-mmq.patch) | `ggml/src/ggml-cuda/mmq.cuh` | Volta Q4_K/Q5_K MMQ configuration routing | [Accepted optimization](docs/findings/accepted-optimizations.md#forced-dp4ammq-for-tested-quantized-prefill) | Exact deterministic output retained | SM70 Q4_K/Q5_K configuration selection only; two audited hunks |

The lossless boundary transport and parallel loader remain accepted findings,
but their source is interleaved with excluded experiments at complete-hunk
boundaries. They are therefore not independently publishable and are not part
of this series. See the machine-readable [`audit.json`](patches/llama.cpp/audit.json)
for the complete retained/excluded accounting.

Application and source-build boundaries are documented in the
[source release guide](docs/source-release.md).
