#!/usr/bin/env bash
set -e

IMAGE="rocq/rocq-prover:latest"
WORKSPACE="/workspace"

echo "🚀 Pulling latest Rocq image (if needed)..."
podman pull $IMAGE

echo "📦 Mounting current directory and running verification..."
# We map the current dir to /workspace and run the script inside opam exec
podman run --rm \
  --security-opt label=disable \
  -v "$(pwd)":$WORKSPACE \
  -w $WORKSPACE \
  $IMAGE \
  bash -c "opam exec -- bash verify.sh"
