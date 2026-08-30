# Source patches

This release is a source-only patch series for the upstream llama.cpp commit
`0d0bfcd4fd8828e3e7906b6fc4561725b534511e` from
<https://github.com/ggml-org/llama.cpp>. It does not publish a fork, binaries,
models, raw experimental data, private configuration, or Git history.

Review the repository-root `PATCHES.md` inventory and
`patches/llama.cpp/audit.json` before applying the series. The audit retains
ten complete hunks: eight for forced DP4A/MMQ selection and two for the Volta
Q4_K/Q5_K MMQ route. It also records two clean semantic reconstructions while
leaving all 576 original mixed or rejected hunks excluded: the parallel model
loader and the lossless mapped-host boundary bridge.

## Exact-base application gate

Run the application helper with a clean llama.cpp checkout whose `HEAD` is the
pinned commit:

```bash
./scripts/apply-patches.sh /path/to/llama.cpp
```

The helper verifies the exact `HEAD` and every patch header, preflights every
patch in lexical order, and only then starts applying the series. A base
mismatch or malformed patch returns nonzero before changing the target tree.

## Native-SM70 build boundary

These patches are source, not a portable build artifact. Project acceptance
requires a CUDA toolchain that can emit native SM70 cubins and a build audit
that finds no PTX fallback. CPU instruction flags must also match the machine
that will execute the resulting binary. A successful patch application alone
does not establish a valid build.

The retained configuration was built with CUDA 12.9 in the
`nvidia/cuda:12.9.2-devel-ubuntu24.04` container. After applying the series,
the following is a concrete CMake configuration for its native-SM70 and
runtime-selector boundaries (run it inside that container with CMake, Ninja,
Git, binutils, and `libcurl4-openssl-dev` installed):

```bash
cmake -S /src -B /build-sm70 -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CUDA_ARCHITECTURES=70-real \
  -DGGML_CUDA=ON \
  -DGGML_CUDA_FA=ON \
  -DGGML_CUDA_FA_ALL_QUANTS=ON \
  -DGGML_CUDA_GRAPHS=ON \
  -DGGML_CUDA_NCCL=OFF \
  -DGGML_CUDA_NO_PEER_COPY=ON \
  -DGGML_CUDA_FORCE_MMQ=OFF \
  -DGGML_CUDA_FORCE_CUBLAS=OFF \
  -DGGML_NATIVE=OFF \
  -DGGML_SSE42=ON -DGGML_AVX=ON -DGGML_AVX2=ON \
  -DGGML_FMA=ON -DGGML_F16C=ON -DGGML_BMI2=ON \
  -DGGML_AVX512=OFF -DGGML_AVX512_BF16=OFF \
  -DGGML_AVX512_VBMI=OFF -DGGML_AVX512_VNNI=OFF \
  -DGGML_AVX_VNNI=OFF \
  -DGGML_CUDA_COMPRESSION_MODE=none \
  -DLLAMA_BUILD_TESTS=ON \
  '-DCMAKE_C_FLAGS_RELEASE=-O3 -DNDEBUG -march=skylake -mtune=skylake' \
  '-DCMAKE_CXX_FLAGS_RELEASE=-O3 -DNDEBUG -march=skylake -mtune=skylake'
cmake --build /build-sm70 --target \
  llama-server test-arg-parser test-llama-file-read-at -j2
```

Here `/src` is the exact pinned and patched checkout. The Skylake CPU flags
match the documented tested host class; change them only after auditing the
actual runtime CPU. `70-real` requests native SM70 code, but the CMake cache is
not sufficient proof: inspect `/build-sm70/bin/libggml-cuda.so` with
`cuobjdump` and require every embedded CUDA image to be an `.sm_70.cubin` with
no PTX entry before treating the build as reproduced. Leaving both compile-time
force options off is required for the patched runtime selector to control MMQ
routing. `GGML_CUDA_NO_PEER_COPY=ON` is required to compile the no-P2P bridge
fallback used by the tested CMP topology.

CMP100-210 is not an ordinary V100. The measured limitations summarized in
[Hardware Limitations](hardware-limitations.md)—including reduced device-local
bandwidth, Gen1 x1 links, host-staged card-to-card movement, and unavailable
CUPTI profiling—remain the starting conditions for build and test decisions.

## Patched runtime selectors

The patch adds one policy with three equivalent input surfaces:

- `--cuda-mmq {auto,force,cublas}` is the command-line selector.
- `LLAMA_ARG_CUDA_MMQ={auto,force,cublas}` is its llama.cpp argument-parser
  environment form.
- `GGML_CUDA_MMQ_MODE={auto,force,cublas}` is the backend environment form read
  by the patched CUDA MMQ dispatcher.

The values have these exact meanings:

- `auto` keeps the pinned llama.cpp dispatch heuristic and is the default when
  no selector is set.
- `force` selects MMQ whenever the pinned backend has a supported MMQ kernel for
  the matrix shape and type.
- `cublas` disables MMQ so cuBLAS is used where applicable; the existing
  small-batch MMVQ path remains enabled.

Precedence is command line, then argument-parser environment, then backend
environment: `--cuda-mmq` overrides `LLAMA_ARG_CUDA_MMQ`, and either parser
surface writes `GGML_CUDA_MMQ_MODE`, replacing a pre-existing backend value.
With neither parser surface present, the backend reads
`GGML_CUDA_MMQ_MODE` directly. Invalid command-line or
`LLAMA_ARG_CUDA_MMQ` values are rejected; an invalid direct backend value logs
a warning and falls back to `auto`.

These values are output-preserving routing selectors only for this pinned
source revision and the documented build/configuration. They do not change
quantization, arithmetic precision, model data, prompts, sampling, or the
exact-output requirement, and they do not establish that another llama.cpp
revision, CUDA build, GPU, model, or request shape chooses the same kernels or
performance outcome.

Two additional default-off environment selectors are included:

- `LLAMA_MODEL_LOAD_PARALLEL=1` loads host tensors first, then overlaps
  independent GPU-context file reads and uploads. It falls back to serial
  loading for mmap, direct I/O, tensor validation, or fewer than two GPU
  contexts.
- `GGML_CUDA_MAPPED_HOST_BRIDGE=1` preserves CUDA allocation ownership in the
  scheduler and carries eligible no-P2P CUDA boundaries through four mapped
  pinned host slots into destination-local memory. It is limited to equal-size
  CUDA tensors no larger than 64 MiB, requires the no-peer-copy build, and is
  disabled when `GGML_CUDA_P2P` is present.

Neither selector changes tensor precision or model data. The loader patch omits
the rejected read-ahead pipeline and load-trace scaffolding. The bridge patch
omits mapped-host FP16, event-scoped bridging, adaptive depth, and superseded
prefill queue experiments.

## Output integrity and performance boundary

Exact deterministic output is a release gate. A change that alters a retained
response is rejected even if status, token count, or marker checks still pass.
The lossy mapped-host FP16 experiment is not included. Reproduction should
follow the matched-clock, full-request, multi-objective process in
[Methodology](methodology.md).

This series carries no performance guarantee. Results are specific to the
documented model, quantization, request shape, card count, clock policy, and
build. Applying or compiling the patches does not show that they improve a
different workload or system.
