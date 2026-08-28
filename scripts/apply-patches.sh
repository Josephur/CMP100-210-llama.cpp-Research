#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "usage: $0 <llama-cpp-checkout>" >&2
    exit 64
fi

target=$1
base_commit='0d0bfcd4fd8828e3e7906b6fc4561725b534511e'
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
    git -C "$target" apply --check "$patch"
done

for patch in "${patches[@]}"; do
    echo "Applying $(basename -- "$patch")"
    git -C "$target" apply "$patch"
done
