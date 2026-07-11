# 🚀 Coq "Hello World" Proof Verification

A lightweight, automated project designed to demonstrate formal proof verification using **Coq** and **GitHub Actions**. 

This project establishes an absolute, mathematically checked proof for a foundational proposition ($A \land B \implies B \land A$) and runs the validation automatically on every commit using a decoupled shell script and a CI runner.

---

## 🛠️ Project Structure

* `hello.v` — The Coq source file containing our logical proposition and formal proof.
* `verify.sh` — A localized bash script that invokes the Coq compiler (`coqc`) to check the proofs.
* `.github/workflows/ci.yml` — A streamlined GitHub Actions pipeline that mirrors the local verification process inside an isolated environment.

---

## 💻 How to Run Locally

### Option 1: Native Coq
If you have Coq installed natively on your machine, simply make the script executable and run it:
```bash
chmod +x verify.sh
./verify.sh
```

### Option 2: Docker Mirror (Matches CI exactly)

If you don't have Coq installed locally, you can mirror the exact GitHub Actions execution environment using Docker:
```bash
docker run --rm -v "$(pwd):/workspace" -w /workspace coqorg/coq:latest ./verify.sh
```

🤖 AI Disclosure & Collaboration

This project was built in collaboration with Gemini (Google AI).

Gemini assisted in:
    Formulating and explaining the formal logic syntax for the Coq proof ecosystem.
    Designing a decoupled CI workflow architecture (separating runner definitions from runtime execution scripts).
    Structuring the localized verification patterns to bridge the gap between personal environments and automated pipelines.
