#!/usr/bin/env python3
"""Reassemble downloaded lab alpha parts and verify the expected SHA-256."""
import hashlib
import os
import sys
import tempfile
from pathlib import Path

if len(sys.argv) != 2 or sys.argv[1] not in {"kernel", "source"}:
    sys.exit("Usage: python3 reassemble-kernel-alpha.py kernel|source")
items = {
    "kernel": ("kernel.deb.part-", 14, "cham-linux-kernel-lab_0.0.1~lab2_amd64.deb",
               "8ab15a12651689819e45a48c280b11e8d46f120ab0c38fd1de2fe7d3ae932fd5"),
    "source": ("ubuntu-source.tar.bz2.part-", 22, "ubuntu-linux-source-6.8.0-149.149.tar.bz2",
               "6aae16a368cc24fe1a6132bf4a012c55c4b3f8bd8c77aca4523937da1b1e3ad4"),
}
prefix, count, output, expected = items[sys.argv[1]]
if Path(output).exists():
    sys.exit(f"Refusing to overwrite {output}; move it first.")
parts = [Path(f"{prefix}{index:02d}") for index in range(count)]
missing = [str(part) for part in parts if not part.is_file()]
if missing:
    sys.exit("Missing parts: " + ", ".join(missing))
digest = hashlib.sha256()
temporary = None
try:
    with tempfile.NamedTemporaryFile(prefix=".cham-reassemble-", dir=".", delete=False) as out:
        temporary = Path(out.name)
        for part in parts:
            with part.open("rb") as source:
                while block := source.read(1024 * 1024):
                    digest.update(block)
                    out.write(block)
    if digest.hexdigest() != expected:
        sys.exit("SHA-256 mismatch; recheck the downloaded parts.")
    os.link(temporary, output)
    print(f"Verified {output}: {expected}")
finally:
    if temporary is not None:
        temporary.unlink(missing_ok=True)
