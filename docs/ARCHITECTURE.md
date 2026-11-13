# Architecture

## Trust boundaries

- Ubuntu LTS owns the host kernel, boot chain, libc, systemd, graphics stack and base packages.
- Cham packages own branding, health reporting, update coordination and hardware profiles.
- Flatpak and Snap applications retain their native update and sandbox models.
- The Arch environment is a rootless Distrobox with a separate home directory. It is for compatibility, not hostile-code isolation.
- Kali is a virtual machine with snapshots and its own updates. Security tools are not installed from Kali repositories onto the host.
- AI tooling is optional. Local services bind to loopback by default; cloud features require explicit credentials and disclosure.

## Update model

`cham update --check` reports each source independently. Stable host updates are installed with APT. Cham packages are delivered through a future signed APT repository. Major OS, firmware, NVIDIA and database migrations are separate maintenance operations with their own recovery gates.

The word latest means latest approved for a channel, not the newest upstream artifact. Candidates move through build, dependency, VM, rollback and physical-hardware tests.
