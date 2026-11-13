# Optional environments

The Arch container provides current developer tools while keeping pacman packages outside the Ubuntu host. Replace `latest` with a tested immutable image digest before a stable release. Rebuilding a candidate container is preferable to performing an unreviewed rolling upgrade in place.

Kali belongs in a VM rather than this Distrobox configuration. Use the official Kali image, verify its checksum/signature, take a clean snapshot, update inside the VM, and restrict shared folders and USB/network access to the active task.
