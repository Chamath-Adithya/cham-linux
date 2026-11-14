#!/usr/bin/env python3
"""Test signing tools using an ephemeral, never-enrolled certificate."""
import subprocess
import tempfile
from pathlib import Path

base = Path(__file__).resolve().parent.parent / "build/kernel-6.8.0-149"


def run(*args):
    subprocess.run([str(arg) for arg in args], check=True, stdout=subprocess.DEVNULL,
                   stderr=subprocess.PIPE)


with tempfile.TemporaryDirectory(prefix="cham-sign-check-") as directory:
    tmp = Path(directory)
    run("openssl", "req", "-x509", "-newkey", "rsa:2048", "-nodes", "-days", "1",
        "-subj", "/CN=Cham temporary signing test/", "-keyout", tmp / "key.pem",
        "-out", tmp / "cert.pem")
    run("openssl", "x509", "-in", tmp / "cert.pem", "-outform", "DER", "-out", tmp / "cert.der")
    run("sbsign", "--key", tmp / "key.pem", "--cert", tmp / "cert.pem", "--output",
        tmp / "kernel.efi", base / "candidate/arch/x86/boot/bzImage")
    run("sbverify", "--cert", tmp / "cert.pem", tmp / "kernel.efi")
    module = tmp / "nvidia-drm.ko"
    module.write_bytes((base / "nvidia-candidate/nvidia-drm.ko").read_bytes())
    run(base / "candidate/scripts/sign-file", "sha256", tmp / "key.pem", tmp / "cert.der", module)
    signer = subprocess.check_output(["modinfo", "-F", "signer", str(module)], text=True).strip()
    if signer != "Cham temporary signing test":
        raise RuntimeError(f"unexpected module signer: {signer!r}")
print("PASS: temporary kernel signature verified and module signed; no key enrolled.")
