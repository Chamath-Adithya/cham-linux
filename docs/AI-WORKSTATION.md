# Cham Linux AI workstation

Cham Linux keeps the Ubuntu host stable and puts rapidly changing AI stacks in
reproducible project environments. The host owns drivers, Secure Boot, laptop
power management, firewalling, backups, and the signed Cham APT package.
Projects own their Python, CUDA libraries, models, agents, and services.

## Product model

| Need | Cham Linux design |
|---|---|
| Local models | Ollama, bound to localhost by default; models are selected per project. |
| GPU projects | Podman/Dev Containers with NVIDIA Container Toolkit validation. |
| Portable projects | Git plus a versioned Dev Container or NVIDIA AI Workbench project specification. |
| Arch tools | Existing rootless Distrobox container. |
| Kali tools | Isolated VM with a snapshot, never an Ubuntu host repository. |
| Recovery | Git-backed Cham package, external backups, and a tested restore procedure. |

## Hardware profile: Lenovo LOQ 15ARP9

The current profile is an RTX 4060 Laptop GPU with 8 GB VRAM. It is suitable for
small and medium local models, coding assistance, transcription, embeddings, and
image workflows chosen to fit memory. Keep model files outside Git and record
their name, digest, quantization, and license in each project README.

Run `cham ai status` to inspect GPU capability, local runtime state, and whether
the Ollama API is exposed on the network.

`cham ai report` creates a bounded, read-only local evidence report. `cham ai
diagnose --allow-heavy MODEL` sends that evidence only to the local Ollama
endpoint and returns structured findings and safe next steps. It cannot execute
its output. The explicit flag prevents an accidental model load. The command
requires at least 6 GiB each of available RAM and free swap plus 4 GiB free GPU
memory; close heavy applications first rather than forcing the laptop into swap
pressure.

## Features to ship

1. **AI health and resource guardrails** — report GPU driver, VRAM, disk space,
   model inventory, API exposure, and container GPU access. Do not start models
   automatically at login.
2. **AI project templates** — a small-model coding template, RAG template, and
   computer-vision template. Each uses Dev Containers, pinned dependencies, and
   a `.env.example`; secrets and models stay out of Git.
3. **Reproducible GPU workspaces** — optional NVIDIA AI Workbench integration for
   projects that need local-to-remote portability. Installation remains opt-in
   because it changes container tooling and storage use.
4. **AI privacy controls** — localhost-by-default inference, firewall audit,
   explicit remote sharing, model license notices, and a preflight check before
   exposing an API.
5. **Rollback-aware updates** — package changelog, signed APT metadata, backup
   preflight, and a restart/suspend validation after kernel or NVIDIA updates.
6. **Kernel observability, not AI kernel mutation** — use existing tracepoints
   and eBPF tools to collect evidence during a controlled test. A proposed
   kernel change requires a reproducible trigger, a separate test kernel,
   rollback boot entry, and suspend/GPU/network validation before promotion.
7. **Local adaptation data** — keep a small, versioned feedback dataset of
   approved diagnoses and outcomes. Train or fine-tune only inside a disposable
   container, evaluate against held-out incidents, and retain the base model and
   rollback path. Raw journals, credentials, private source code, and browser
   data are excluded by default.

## Non-goals

Cham Linux does not merge Arch or Kali package repositories into Ubuntu. It does
not install large model downloads, cloud credentials, telemetry, or background
agents without an explicit project-level request.

## Delivery order

The first release adds diagnostics and templates. The second release validates
GPU-enabled Dev Containers on the LOQ profile. NVIDIA AI Workbench is evaluated
in a separate profile only after a backup and a clean rollback test.
