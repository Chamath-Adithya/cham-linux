# Cham Linux

Cham Linux is an Ubuntu LTS based workstation product focused on reliable updates, recovery, developer tooling, AI workloads, and a consistent desktop. The host keeps one supported Ubuntu dependency graph. Arch tools run in a rootless development container and Kali runs in a VM.

Current channel: `alpha`. Current supported hardware profile: Lenovo LOQ 15ARP9 with Ryzen 7 7435HS and RTX 4060 Laptop GPU.

## Commands

```bash
./bin/cham doctor
./bin/cham status
./bin/cham update --check
./bin/cham experience status
./bin/cham ai status
./bin/cham release-preflight
```

Repair the currently detected Ubuntu testing-pocket and duplicate-source issue only after reviewing the script:

```bash
sudo ./system/repair-sources.sh
```

Build the Cham package without root:

```bash
make package
```

Enable native Cham Linux updates once on a new Ubuntu 24.04 installation:

```bash
sudo ./install-apt-repository.sh
```

After that, Ubuntu, official third-party applications, and Cham Linux packages
use the normal APT workflow:

```bash
sudo apt update
sudo apt upgrade
```

## Desktop experience

Cham Experience is a small, reversible GNOME user layer: a calm dark-blue
visual system, original Cham Horizon wallpaper, battery percentage, weekday
clock, practical window tiling, compact dock, and a branded application menu.
It uses per-user `gsettings` values only; it never overwrites GNOME, Ubuntu, or
driver files.

```bash
cham experience apply
cham experience status
cham experience reset
```

The application launcher is named **Cham Experience**. `reset` changes only
the settings set by this profile back to GNOME defaults.

Create the Arch development container after reviewing `containers/distrobox.ini`:

```bash
distrobox assemble create --file containers/distrobox.ini
```

The repository contains product source and reproducible configuration. Personal files, credentials and database contents belong in encrypted external backups.

See [architecture](docs/ARCHITECTURE.md), [AI workstation](docs/AI-WORKSTATION.md), [release process](docs/RELEASE.md), [recovery](docs/RECOVERY.md), and the [LOQ validation procedure](docs/LOQ-VALIDATION.md).
