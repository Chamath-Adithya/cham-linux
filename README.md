# Cham Linux

**A personal Linux workstation project, growing into a community.** Cham Linux
brings a distinct desktop, practical diagnostics, recovery planning and a
thoughtful update experience to an Ubuntu LTS foundation.

> **Early alpha:** this project is under active development. There is no
> general-purpose Cham Linux installation ISO or validated stable release yet.
> Features, hardware support and update procedures can change. Use a test
> system and make a verified backup before trying system-level changes.

## What makes Cham Linux different?

- **Cham Experience:** a reversible GNOME appearance profile with original
  Cham artwork and sensible desktop settings.
- **Workstation diagnostics:** inspect updates, services, hardware and selected
  configuration risks with the `cham` command.
- **A consistent foundation:** Ubuntu 24.04 LTS supplies the host packages;
  Cham adds its own tools and presentation. Updates retain their source and
  trust boundaries.
- **Room to experiment:** Arch tools can run in a Distrobox environment, while
  Kali can be used separately in a VM. Their package repositories are not
  mixed into the Ubuntu host.

Cham Linux has its own identity and goals, but it is currently **Ubuntu-based**.
It is not an independently built operating system, and it is not an official
Ubuntu or Kali product. Ubuntu, Linux, Kali and other names belong to their
respective owners.

## Current status

The main development machine is a Lenovo LOQ 15ARP9 with a Ryzen 7 7435HS and
RTX 4060. Passing a test on that machine does not establish compatibility with
other devices. The separate [experimental kernel prerelease][kernel-alpha]
contains a test package, not an OS installer. It is unsigned for Secure Boot,
is not delivered through APT, and does not receive automatic security updates.
Read its limitations before considering a test.

Cham packages and Ubuntu packages can use APT once the Cham archive has been
configured. Flatpak, Snap, firmware and containers have their own update
mechanisms. The existing Cham APT suite is named `stable` for compatibility,
but its contents are **alpha**, not a validated stable channel.

## Explore the project

Start by reading [the architecture](docs/ARCHITECTURE.md),
[recovery guidance](docs/RECOVERY.md) and [release process](docs/RELEASE.md).
Learn about the project's purpose and current limits in the
[product story](docs/PRODUCT-STORY.md). Read the proposed path toward an
independently maintained distribution in the [product architecture](docs/PRODUCT-ARCHITECTURE.md)
and the [distribution research and security automation plan](docs/DISTRIBUTION-RESEARCH.md).
The initial, limited upstream notice matching process is described in
[security triage](docs/SECURITY-TRIAGE.md).
On a compatible Ubuntu test installation, review scripts before running them.
To build the Cham package from a checkout without installing it:

```sh
make package
```

The `cham` tool provides diagnostics such as `cham status`, `cham doctor` and
`cham update --check`. Run `cham --help` or inspect `bin/cham` for the version
you are using. Do not run host repair scripts without reading what they change.

## Join the community

Your experience can help shape Cham Linux: report a reproducible problem,
suggest an improvement, review documentation or share a hardware test result.
Start with [CONTRIBUTING.md](CONTRIBUTING.md) and our
[community guidelines](CODE_OF_CONDUCT.md). Use [Issues][issues] for bugs and
feature requests and [Discussions][discussions] for questions and ideas.
Please review [SECURITY.md](SECURITY.md) before sharing security-sensitive
information.

Cham-owned software and documentation are available under GPL-3.0-or-later.
See [LICENSE](LICENSE) and [LICENSING.md](LICENSING.md) for scope and
third-party components, which retain their own licenses.

Project code and configuration belong in version control. Personal files,
recovery keys and databases belong in appropriate encrypted backups, not Git.

[issues]: https://github.com/Chamath-Adithya/cham-linux/issues
[discussions]: https://github.com/Chamath-Adithya/cham-linux/discussions
[kernel-alpha]: https://github.com/Chamath-Adithya/cham-linux/releases/tag/kernel-alpha-0.0.1-lab2
