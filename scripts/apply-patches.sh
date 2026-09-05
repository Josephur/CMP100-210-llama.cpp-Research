#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <llama-cpp-checkout>" >&2
    exit 64
fi

target=$1
base_commit='25b03bd5b987e4e8b11691c42afc3f317a9d1515'
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
series_dir="$script_dir/../patches/llama.cpp"

test "$(git -C "$target" rev-parse --is-inside-work-tree 2>/dev/null)" = true
test "$(git -C "$target" rev-parse HEAD)" = "$base_commit"
test -z "$(git -C "$target" status --porcelain)"

shopt -s nullglob
patches=("$series_dir"/[0-9][0-9][0-9][0-9]-*.patch)
test "${#patches[@]}" -gt 0

for patch in "${patches[@]}"; do
    grep -Fqx "Base-Commit: $base_commit" "$patch"
done

# The series is ordered and cumulative: later patches build on earlier ones, so
# each patch cannot be validated against the pristine base in isolation. Applying
# the whole series in one invocation validates and applies it in order, and leaves
# the checkout untouched if any patch in the series does not apply.
for patch in "${patches[@]}"; do
    echo "Applying $(basename -- "$patch")"
done
git -C "$target" apply "${patches[@]}"
