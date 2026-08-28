# Hardware Limitations

The CMP100-210 is Volta `sm_70` silicon, but it is **not an ordinary V100**.
V100/GV100 materials are useful for architectural hypotheses only; they do not
prove the behavior of this board configuration.

| Property | Measured or product-specific constraint | Consequence for this research |
| --- | --- | --- |
| Card memory | 16 GiB HBM2 per card | Large models require layer sharding across cards. |
| Device-local copy | Roughly 350–377 GB/s in this environment | Local data is comparatively fast once resident. |
| Host link | Gen1 x1, roughly 200 MB/s measured for large transfers | Transfer bursts and host staging are major constraints. |
| Card-to-card path | no CUDA P2P/NVLink | Layer-boundary movement is host staged. |
| Clocks | dynamic idle can reach 135 MHz; comparison lock is 1,380 MHz | Fixed selected-card clocks are mandatory for fair runs. |
| Volta features | no modern INT4 Tensor Core MMA, BF16, TF32, `cp.async`, or TMA | Modern CUDA tuning advice may not map to this workload. |
| Counter tooling | CUPTI is disabled on this product | Hardware-counter campaigns are unavailable; use SASS, CUDA events, narrow instruction attribution, telemetry, and physical A/B tests. |

## Practical effect

Six cards provide capacity, not a single six-times-larger GPU. Layer ownership
creates serial boundaries: a card computes its layers, waits for the next
activation boundary, and resumes. A low average SM-duty trace can therefore be
dependency waiting rather than continuous PCIe saturation.

The useful strengths are fast card-local HBM2, strong DP4A for appropriate
quantized shapes, stable operating temperatures, and closely matched cards.
Candidate work should keep data local, minimize host/inter-card boundaries,
and favor simple occupancy-conscious SM70 kernels.
