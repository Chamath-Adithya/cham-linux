# Architecture

## Trust boundaries

- Ubuntu LTS owns the host kernel, boot chain, libc, systemd, graphics stack and base packages.
- Cham packages own branding, health reporting, update coordination and hardware profiles.
- Flatpak and Snap applications retain their native update and sandbox models.
- The Arch environment is a rootless Distrobox with a separate home directory. It is for compatibility, not hostile-code isolation.
- Kali is a virtual machine with snapshots and its own updates. Security tools are not installed from Kali repositories onto the host.
- AI tooling is optional. Local services bind to loopback by default; cloud features require explicit credentials and disclosure.

## Update model

`cham update --check` reports each source independently. Ubuntu host updates
use APT. Cham packages also have a signed APT repository; its suite is named
`stable` but currently contains alpha packages and is not a validated stable
channel. Flatpak, Snap, firmware and containers have separate update systems.
Major OS, firmware, NVIDIA and database migrations are separate maintenance
operations with their own recovery gates. The experimental kernel prerelease
is distributed separately and does not receive automatic APT security updates.

The word latest means latest approved for a channel, not the newest upstream artifact. Candidates move through build, dependency, VM, rollback and physical-hardware tests.
