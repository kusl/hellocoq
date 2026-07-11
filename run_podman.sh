#!/usr/bin/env bash
set -e

IMAGE="rocq/rocq-prover:latest"
WORKSPACE="/workspace"

echo "🚀 Pulling latest Rocq image (if needed)..."
podman pull $IMAGE

echo "📦 Mounting current directory and running verification..."
podman run --rm \
  --security-opt label=disable \
  -v "$(pwd)":$WORKSPACE \
  -w $WORKSPACE \
  $IMAGE \
  bash verify.sh
