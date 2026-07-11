#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "========================================="
echo " Starting Coq Proof Verification..."
echo "========================================="

# 1. Check if coqc is available
if ! command -v coqc &> /dev/null; then
    echo "Error: coqc (Coq Compiler) is not installed or not in your PATH."
    exit 1
fi

# 2. Compile the Coq file
echo "Compiling hello.v..."
coqc hello.v

echo "========================================="
echo " Success: All proofs verified by Coq! ✅"
echo "========================================="
