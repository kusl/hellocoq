# Rocq "Hello World" Proof Verification

A minimal, automated project that machine-checks a formal proof with the
[Rocq Prover](https://rocq-prover.org/) (formerly Coq) on every push.

The proposition proved is commutativity of conjunction: $A \land B \implies B \land A$.

---

## Project structure

| File | Purpose |
| --- | --- |
| `hello.v` | The Rocq source: the proposition and its proof. |
| `verify.sh` | The whole build. Runs the checks inside the official Rocq container, or natively with `--native`. |
| `.github/workflows/ci.yml` | Checkout, then `bash verify.sh`. That's it. |
| `export.sh` | Unrelated helper: dumps the repo to `docs/llm/dump.txt` for LLM context. |

CI runs the same script you run locally, so there is no second copy of the
build logic to keep in sync.

---

## Running it

```bash
./verify.sh              # pull the latest Rocq image and verify (podman, else docker)
./verify.sh --no-pull    # reuse the image already on disk
./verify.sh --native     # use the rocq (or coqc) already installed on your PATH
./verify.sh --help
```

The script resolves its own location, so it works from any working directory.

Useful overrides:

```bash
ROCQ_IMAGE=docker.io/rocq/rocq-prover:9.2 ./verify.sh   # pin a version
CONTAINER_ENGINE=docker ./verify.sh                     # force an engine
```

Sources are copied into a scratch directory before compiling, so `.vo`,
`.glob` and `.aux` files never land in your worktree.

### Poking around interactively

```bash
podman run --rm -it \
  --security-opt label=disable \
  --userns=keep-id \
  -v "$PWD":/work -w /work \
  docker.io/rocq/rocq-prover:latest bash
```

`--userns=keep-id` maps your host UID onto the container's `rocq` user so you
can actually write files in `/work`. Inside, use `rocq compile hello.v` or
`rocq repl`.

---

## A note on `coqc` vs `rocq compile`

Rocq 9.0 renamed the command-line tools. The `rocq/rocq-prover` images install
`rocq-core` but deliberately skip the transitional `coq-core` package, so
**there is no `coqc` binary in the image**:

| Coq ≤ 8.20 | Rocq ≥ 9.0 |
| --- | --- |
| `coqc f.v` | `rocq compile f.v` |
| `coqtop` | `rocq repl` |
| `coqdep` | `rocq dep` |
| `coq_makefile` | `rocq makefile` |
| `coqchk` | `rocq check` |

`verify.sh` prefers `rocq` and falls back to `coqc`, so it also works against
an older native Coq install.

The image's `ENTRYPOINT` is `opam exec --`, which already puts the opam switch
on `PATH` — no manual `PATH` surgery is needed.

---

## Scaling past one file

`verify.sh` compiles every `.v` file it finds, in alphabetical order. Once
files start depending on each other, add a `_CoqProject` and switch the loop to
`rocq makefile -f _CoqProject -o Makefile.coq && make -f Makefile.coq`.

---

## AI disclosure

Built in collaboration with Gemini (Google AI) for the original Coq proof and
CI scaffolding, and Claude (Anthropic) for the migration to the Rocq 9.x
toolchain and the single-entry-point build script.
