# Cham Linux: product direction and engineering roadmap

Status: proposal, not a description of shipped capabilities. Cham today is an
Ubuntu-based system with Cham packages; the developer installer is a draft.

## Product promise

Make a Linux laptop easier to understand, update and recover, while giving its
owner control. Start with documented, repeatable support for a small hardware
set; expand only when test evidence exists. Respect user privacy and upstream
projects, and describe supported capabilities without promising zero bugs.

## Problems to validate

These are hypotheses drawn from the project's experience, not claims that all
other distributions have these defects. Interview prospective users and collect
opt-in, redacted reports before prioritizing.

1. Updates span operating system packages, apps, firmware and isolated tool
   environments; users may not know which step failed or needs a reboot.
2. Laptop GPU, suspend, firmware and Secure Boot interactions are difficult to
   diagnose and vary by hardware and driver version.
3. Backups, boot recovery and rollback are often hard to verify in practice.
4. System messages can be difficult to turn into a safe, understandable action.

## Proposed Cham components

* **Update overview**: report source, version, security status when reliably
  known, pending reboot, and per-source results. Preview changes and run the
  native updater for each enabled source. A failed step must remain visible;
  never silently disable signature checks or remove packages. Automate security
  updates only where the source supports them and the user enables the policy.
* **Hardware passport**: locally record model, kernel, drivers, firmware and
  results of opt-in checks, including suspend on AC and battery. Show unknown
  results honestly; never upload hardware identifiers without consent.
* **Recovery readiness**: show encrypted backup destination, age and the date of
  the last actual restore test. Snapshot/rollback is a future design requiring
  filesystem and boot integration; it is not a substitute for offline backup.
* **Explain and repair**: a local, on-demand diagnostic that shows evidence,
  proposes a specific action and obtains approval before changes. Any small
  model is optional, benchmarked, and cannot directly operate privileged tools.
  Collection and training are opt-in and have an explicit deletion policy.
* **Tool environments**: provide optional isolated Kali or Arch environments
  with separate package managers and update results. Keep environment lifecycle,
  storage use and trust boundaries visible to the user.

## Update and distribution architecture

Keep a single coherent host base and its signed repositories. Do not add Kali
repositories to Ubuntu or mix Arch binary packages into the host. An isolated
environment remains subject to its own distribution's maintenance policy.
Cham can select upstream source components, review their licenses and patches,
build against the chosen base, test, sign and publish its own packages. Upstream
security changes require tracking, triage, backporting where necessary and timely
publication; they do not automatically become safe Cham updates.

The long-term possibility of an independent distribution requires a maintained
source and binary archive, build infrastructure, dependency and ABI management,
security response, signing key lifecycle, reproducible builds, installer,
bootloader and driver support, mirrors, upgrade paths, legal compliance and a
maintainer community. A name change or custom kernel alone does not provide
independence. Maintain Ubuntu as the current base until a separate prototype
demonstrates this infrastructure and a sustainable security maintenance plan.

## Delivery gates

1. Finish the installer prototype: first graphical boot, offline/error behavior,
   recovery documentation, license review and tests on disposable virtual disks.
2. Build a read-only hardware and update overview, with fixture tests and clear
   source-specific status; no automatic repairs in the first version.
3. Validate Secure Boot, signed GPU drivers, boot and suspend/resume on supported
   hardware and publish results with exact firmware, kernel and driver versions.
4. Add opt-in update execution and recovery checks after failure-path tests;
   validate rollback on each supported filesystem before advertising it.
5. Prototype an independent base separately, with security-update service
   ownership and migration/rollback plans, before proposing a production switch.

Release channels should distinguish experimental builds from stable releases;
stable requires automated tests, representative hardware tests and a documented
rollback. No release may promise universal compatibility or zero conflicts.

## Research starting points

* Kali warns against mixing its repository with Ubuntu:
  https://www.kali.org/docs/general-use/kali-apt-sources/
* Arch documents why partial upgrades are unsupported:
  https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported
* Ubuntu explains phased package updates:
  https://documentation.ubuntu.com/project/how-ubuntu-is-made/concepts/phased-updates/
* Fedora Silverblue documents an established rollback approach:
  https://docs.fedoraproject.org/en-US/fedora-silverblue/updates-upgrades-rollbacks/
