#!/usr/bin/env bash
set -e

IMAGE="rocq/rocq-prover:latest"
WORKSPACE="/workspace"

echo "🚀 Pulling latest Rocq image (if needed)..."
podman pull $IMAGE

echo "📦 Mounting current directory and running verification..."
# 1. -e HOME=/home/rocq forces the environment back to the container's native user
# 2. bash -l makes it a login shell so it inherits all container profiles
# 3. opam exec --root=... strictly locks the package manager to the right directory
podman run --rm \
  --security-opt label=disable \
  -e HOME=/home/rocq \
  -v "$(pwd)":$WORKSPACE \
  -w $WORKSPACE \
  $IMAGE \
  bash -l -c "opam exec --root=/home/rocq/.opam -- bash verify.sh"
