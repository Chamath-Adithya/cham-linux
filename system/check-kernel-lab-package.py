#!/usr/bin/env python3
"""Inspect a local experimental kernel package without installing it."""
import hashlib
import subprocess
import sys
import tarfile
from pathlib import Path

if len(sys.argv) != 2:
    sys.exit("Usage: check-kernel-lab-package.py path/to/package.deb")
package = Path(sys.argv[1])
release = "6.8.12-cham-lab1"
expected_image = "ea4d99c127da722c323bebafd5c9981b946ed418041076e91c66715ab4f7671f"
image_path = f"./boot/vmlinuz-{release}"
modules = {f"./lib/modules/{release}/updates/cham-test/{name}.ko" for name in
           ("nvidia", "nvidia-drm", "nvidia-modeset", "nvidia-uvm", "nvidia-peermem")}
seen = set()
image_hash = None
process = subprocess.Popen(["dpkg-deb", "--fsys-tarfile", str(package)], stdout=subprocess.PIPE)
assert process.stdout is not None
try:
    with tarfile.open(fileobj=process.stdout, mode="r|") as archive:
        for member in archive:
            name = member.name
            if name.endswith((".pem", ".key", ".priv")) or "signing_key" in name:
                raise ValueError(f"Signing material found in package: {name}")
            if name in (f"./lib/modules/{release}/build", f"./lib/modules/{release}/source"):
                raise ValueError(f"Unexpected build/source link: {name}")
            if name in modules:
                if not member.isfile() or member.mode & 0o444 != 0o444:
                    raise ValueError(f"Invalid module permissions or type: {name}")
                seen.add(name)
            if name == image_path:
                content = archive.extractfile(member)
                if content is None:
                    raise ValueError("Kernel image is not a regular file")
                image_hash = hashlib.file_digest(content, "sha256").hexdigest()
finally:
    process.stdout.close()
    result = process.wait()
if result:
    sys.exit(f"dpkg-deb failed with exit code {result}")
if image_hash != expected_image or seen != modules:
    sys.exit(f"Package verification failed: image={image_hash}; missing modules={modules - seen}")
print("PASS: expected kernel image and five readable NVIDIA modules; no signing material or build links.")
