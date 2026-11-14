# Cham Linux: a workstation that explains itself

Cham Linux is an early-stage, Ubuntu-based workstation project for people who
want a welcoming everyday desktop alongside development, security learning
and optional local-AI tools. Its ambition is to make the system easier to
understand, update, personalize and recover — and to develop those improvements
with a community.

## Why build it?

Developers and learners may use packages, containers, security tools and AI
workloads on the same laptop. Those tools have different update mechanisms,
hardware requirements and recovery needs. A person should not have to guess
which system component changed or copy unrelated commands without understanding
their impact. Cham aims to provide a coherent home for those workflows while
keeping familiar upstream maintenance and giving people control of changes.

## What exists today

- Ubuntu 24.04 LTS provides the host package and security-update foundation.
- Cham Experience provides original branding and a reversible GNOME appearance
  profile. The `cham` tool provides diagnostics and update visibility.
- Cham packages can be updated with APT once the Cham archive is configured.
  Flatpak, Snap, firmware, containers and experimental kernels have separate
  update mechanisms and should not be described as covered by APT alone.
- The project is public, welcomes community feedback and licenses Cham-owned
  code and documentation under GPL-3.0-or-later. Upstream components retain
  their own licenses.
- A separately distributed experimental kernel has passed initial GPU/CUDA
  and short suspend tests on one Lenovo LOQ laptop. It is not a general-purpose
  signed kernel release and does not receive automatic security updates.

The main repository and individual development machines may not contain the
same experimental changes. Check a release's contents and test evidence before
promising a feature to users.

## The opportunity — and the limits of today's solution

| Need or trade-off | Cham's approach | Honest status |
| --- | --- | --- |
| A recognizable, personal desktop | Reversible Cham GNOME settings and artwork | Alpha; not a complete new desktop environment |
| Ubuntu stability with security-learning tools | Ubuntu host; Kali in a separate VM, Arch in a separate container | Keeps dependency graphs separate; guest updates remain separate |
| Understand updates from different sources | Diagnostics and Cham APT packages | APT does not update every app format or firmware; a unified experience needs further validation |
| Recover when a system change goes wrong | Recovery guidance and backup tooling | An external backup and restore test are still essential |
| Better laptop hardware behaviour | Measure and test GPU, drivers, power and suspend | Initial LOQ evidence only; the firmware ACPI warning and wider hardware testing remain open |
| Private, useful local AI | On-demand, opt-in diagnostics are the direction | No claim of a trained autonomous OS model or guaranteed performance improvement |
| Easy installation | Reproducible installation media and onboarding | Experimental installer work; no generally validated Cham ISO yet |

Ubuntu already has capable software and update tools; Cham's opportunity is
to bring a coherent experience around its chosen workflows. Kali is designed
for security professionals and Arch prioritizes user control. They solve
different problems. Mixing Kali repositories into an Ubuntu host is explicitly
discouraged by Kali because it can break the system:
https://www.kali.org/docs/general-use/kali-apt-sources/

## Who it is for now

Today: curious testers, Linux developers, documentation contributors and
hardware testers who understand alpha software and have a recovery plan.
Longer term: people who want a practical daily workstation with optional
developer and security environments. Do not market unvalidated features as
finished or imply endorsement by Ubuntu, Kali, Arch, NVIDIA or Lenovo.

## Community pitch

> **Cham Linux — a personal workstation, built in the open.** A familiar
> Ubuntu foundation, a Cham identity, and tools that help you understand your
> system. Join us in testing, documenting and building the experience.

## Sources and distribution

Cham is Ubuntu-based, not a kernel or operating system created from scratch.
Ubuntu's trademark and redistribution policy applies to modified images:
https://ubuntu.com/legal/intellectual-property-policy
Kali's intended use is described at:
https://www.kali.org/docs/introduction/should-i-use-kali-linux/
