#!/usr/bin/env bash
set -e

echo "========================================="
echo " Starting Coq Proof Verification..."
echo "========================================="

# 💡 FIX: Manually find and inject the container's compiler paths into $PATH
# This bypasses opam's user/root restrictions completely
for opam_bin in /home/rocq/.opam/*/bin /home/rocq/.opam/*/*/bin; do
    if [ -d "$opam_bin" ]; then
        export PATH="$opam_bin:$PATH"
    fi
done

# 1. Check if coqc is available
if ! command -v coqc &> /dev/null; then
    echo "Error: coqc (Coq Compiler) is not installed or not in your PATH."
    echo "Current PATH search space: $PATH"
    exit 1
fi

# 2. Compile the Coq file
echo "Compiling hello.v..."
coqc hello.v

echo "========================================="
echo " Success: All proofs verified by Coq! ✅"
echo "========================================="
