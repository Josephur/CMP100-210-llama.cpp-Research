# Measurement Summary

This table is a compact public view of selected decisions. It is not a
leaderboard: rows compare only their stated matched configuration. The
repository-root `data/selected-results.csv` contains the corresponding
machine-readable rows; see [methodology](../methodology.md) for field
definitions and limits.

| Finding | Status | Scope | Measured result | Integrity |
| --- | --- | --- | --- | --- |
| Forced DP4A/MMQ prefill | accepted | six-card Qwen3.5-122B-A10B UD-Q4_K_XL, 128K | 2.36x matched prefill throughput versus automatic policy | byte-exact |
| Mapped-host FP16 transport | rejected | six-card Qwen3.5-122B-A10B UD-Q4_K_XL, 32K/100K | small prompt gain and reduced boundary traffic | changed deterministic output |
| Grouped MoE tile candidate | rejected | six-card Qwen3.5-122B-A10B quantized MoE, 100K | isolated operation faster; complete request neutral | byte-exact but not material |

All rows are `configuration_specific`. Absolute rates, if useful for a future
reproduction, must be taken from a complete released record rather than
inferred from this compact decision table.
