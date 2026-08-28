# CMP100-210 llama.cpp Research

> **WORK IN PROGRESS — EXPERIMENTAL RESEARCH — NO CLAIMS, WARRANTIES, OR GUARANTEES.**

This repository publishes configuration-scoped llama.cpp research for NVIDIA
CMP100-210 GPUs. It deliberately includes successful and unsuccessful
experiments so that a plausible mechanism is not mistaken for a repeatable
end-to-end gain.

These are observations from controlled experiments on one six-card CMP100-210
configuration. They are not a comparison to a full V100, a prediction for
another host, a recommendation to change firmware, or a guarantee of model
quality or speed.

## What is here

- [Methodology](docs/methodology.md): the clock, output-integrity, and
  measurement rules used for comparable runs.
- [Hardware limitations](docs/hardware-limitations.md): the measured CMP
  constraints that shape every hypothesis.
- [Accepted optimizations](docs/findings/accepted-optimizations.md) and
  [rejected ideas](docs/findings/rejected-ideas.md): bounded decision records.
- [Measurement summary](docs/findings/measurement-summary.md) and the
  machine-readable [selected results](data/selected-results.csv).

The browser portal is built from the same public documents with MkDocs. It is
not a live benchmark dashboard and contains no model weights, binaries, raw
prompts, raw completions, service configuration, or deployment tooling.

## Scope and integrity policy

Every accepted result is tied to a model, quantization, card count, context,
clock policy, and deterministic-output check. A faster run that changes a
retained deterministic response is rejected for this project, even when its
HTTP response, marker checks, or token count appear healthy.

This repository is a curated export. The active laboratory environment and its
private evidence stay private by design.

## License and attribution

Project-authored code is [MIT licensed](LICENSE). Project-authored prose,
diagrams, and summarized datasets are under [CC BY 4.0](LICENSE-docs).
Third-party terms and links are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
