# Cham installer prototype

This is a **local development prototype**, not a production ISO. It combines
an official Ubuntu 24.04.5.1 Desktop installer with the Cham core package and
an interactive autoinstall configuration. The Ubuntu installer retains its
normal questions, including storage selection. A late command checks the
included package, configures the signed Cham alpha APT source, and installs
Cham core into the target. Internet access is required for dependencies.

The default installer UI and base system remain Ubuntu. Cham Experience is
available after login; branding is not applied automatically. This media does
not install the experimental Cham kernel. It does not yet demonstrate a full
installation, upgrade, removal, rollback, Secure Boot or physical hardware
compatibility. Do not use it on real disks or distribute it as a finished OS.

## Build

Install `xorriso`, `gpgv`, `ripgrep`, `curl`, `dpkg-dev`, and the Ubuntu
archive keyring, then run from a clean, committed checkout:

```sh
bash iso/build-dev-iso.sh /path/to/ubuntu-24.04.5.1-desktop-amd64.iso /path/to/output.iso
```

The script verifies the ISO against Canonical's signed checksum list and builds
the Cham package from the committed checkout in a temporary directory. It
requires the source file name `ubuntu-24.04.5.1-desktop-amd64.iso` and pins
its checksum. Output must be a new file. Review the
configuration and test only with disposable virtual disks. No production key,
personal files or user configuration should be placed in the image.

Canonical's trademark and redistribution policy applies to modified Ubuntu
images: https://ubuntu.com/legal/intellectual-property-policy. Review the
policy and component licenses before any public redistribution.
