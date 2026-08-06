#!/usr/bin/env bash
# =============================================================================
# verify.sh — machine-check every Rocq (.v) file in this repository.
#
#   ./verify.sh              run the checks inside the official Rocq container
#                            (podman if present, else docker)
#   ./verify.sh --no-pull    reuse the image already on disk, skip the pull
#   ./verify.sh --native     use the rocq / coqc already installed on $PATH
#
# CI runs the exact same command, so your laptop and the GitHub runner execute
# byte-for-byte identical steps.
#
# Overrides: ROCQ_IMAGE=...   CONTAINER_ENGINE=podman|docker
# =============================================================================
set -euo pipefail

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
REPO_ROOT="$(dirname "$SELF")"
SELF_NAME="$(basename "$SELF")"

IMAGE="${ROCQ_IMAGE:-docker.io/rocq/rocq-prover:latest}"
NATIVE=0
PULL=1

for arg in "$@"; do
    case "$arg" in
        --native)   NATIVE=1 ;;
        --no-pull)  PULL=0 ;;
        -h|--help)  awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$SELF"; exit 0 ;;
        *)          echo "verify.sh: unknown option '$arg' (try --help)" >&2; exit 2 ;;
    esac
done

BUILD_DIR=""
cleanup() { if [[ -n "$BUILD_DIR" ]]; then rm -rf "$BUILD_DIR"; fi; }
trap cleanup EXIT

# -----------------------------------------------------------------------------
# The actual verification. Runs natively, or inside the container (same code).
# -----------------------------------------------------------------------------
run_checks() {
    local compiler
    if command -v rocq >/dev/null 2>&1; then
        compiler=rocq            # Rocq >= 9.0 : `rocq compile foo.v`
    elif command -v coqc >/dev/null 2>&1; then
        compiler=coqc            # Coq  <= 8.20: `coqc foo.v`
    else
        echo "verify.sh: neither 'rocq' nor 'coqc' is on \$PATH" >&2
        echo "           PATH=$PATH" >&2
        exit 1
    fi

    local -a sources=()
    local src rel
    while IFS= read -r -d '' src; do
        sources+=("${src#"$REPO_ROOT"/}")
    done < <(find "$REPO_ROOT" -type f -name '*.v' -not -path '*/.git/*' -print0 | sort -z)

    if (( ${#sources[@]} == 0 )); then
        echo "verify.sh: no .v files found under $REPO_ROOT" >&2
        exit 1
    fi

    echo "========================================="
    echo " Rocq proof verification"
    echo " compiler : $("$compiler" --version 2>/dev/null | head -n1)"
    echo " sources  : ${#sources[@]} file(s) under $REPO_ROOT"
    echo "========================================="

    # Compile a scratch copy rather than the worktree itself: the repo is
    # mounted read-only in the container (a rootless container cannot write
    # there anyway), and this keeps .vo/.glob/.aux droppings out of your repo.
    BUILD_DIR="$(mktemp -d)"
    for rel in "${sources[@]}"; do
        mkdir -p "$BUILD_DIR/$(dirname "$rel")"
        cp "$REPO_ROOT/$rel" "$BUILD_DIR/$rel"
    done
    [[ -f "$REPO_ROOT/_CoqProject" ]] && cp "$REPO_ROOT/_CoqProject" "$BUILD_DIR/"

    cd "$BUILD_DIR"
    for rel in "${sources[@]}"; do
        echo "  -> $rel"
        if [[ $compiler == rocq ]]; then
            rocq compile "$rel"
        else
            coqc "$rel"
        fi
    done

    echo "========================================="
    echo " Success: all proofs verified"
    echo "========================================="
}

# -----------------------------------------------------------------------------
# Re-run this same script inside the official Rocq image.
# -----------------------------------------------------------------------------
run_in_container() {
    local engine="${CONTAINER_ENGINE:-}"
    if [[ -z "$engine" ]]; then
        if   command -v podman >/dev/null 2>&1; then engine=podman
        elif command -v docker >/dev/null 2>&1; then engine=docker
        else
            echo "verify.sh: no podman or docker found." >&2
            echo "           Install one, or run '$SELF --native'." >&2
            exit 1
        fi
    fi

    if (( PULL )); then
        echo "Pulling $IMAGE with $engine ..."
        "$engine" pull "$IMAGE"
    fi

    # The image's ENTRYPOINT is `opam exec --`, so the opam switch (and the
    # rocq binary) is already on PATH. Nothing to set up by hand.
    exec "$engine" run --rm \
        --security-opt label=disable \
        -e ROCQ_IN_CONTAINER=1 \
        -v "$REPO_ROOT":/workspace:ro \
        -w /workspace \
        "$IMAGE" \
        bash "/workspace/$SELF_NAME"
}

if (( NATIVE )) || [[ "${ROCQ_IN_CONTAINER:-0}" == 1 ]]; then
    run_checks
else
    run_in_container
fi
