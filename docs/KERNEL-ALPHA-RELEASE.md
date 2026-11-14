# Cham Linux kernel lab alpha 0.0.1~lab2

This is an experimental kernel package for evaluation on a Lenovo LOQ 15ARP9
with an NVIDIA RTX 4060. It is not a stable Cham Linux release or a general
installation image. It is not published to the Cham APT repository and does
not automatically receive security updates. Continue using a supported Ubuntu
kernel as the default and retain a tested recovery path.

The kernel is based on Ubuntu `linux-source-6.8.0` version `6.8.0-149.149`,
with the patch in `kernel/patches/`, and identifies itself as
`6.8.12-cham-lab1`. The Debian package is `cham-linux-kernel-lab` version
`0.0.1~lab2`. It includes NVIDIA open kernel modules 580.178.04 and is intended
for that driver version. It does not include a general DKMS headers package.
The Ubuntu source archive, NVIDIA open module source, license notices, kernel
configuration and Ubuntu public certificate bundles accompany the binary.
`SHA256SUMS` records the assets; these hashes are not a cryptographic release
signature. The build contains a locally generated module-signing public key;
its private key is not distributed. A rebuild is not claimed bit-reproducible.

The kernel package and Ubuntu source archive are distributed in numbered
parts because large direct uploads timed out. Download all `kernel.deb.part-*`
files and `reassemble-kernel-alpha.py` to the same directory, then run
`python3 reassemble-kernel-alpha.py kernel`. To reconstruct the Ubuntu source,
download all `ubuntu-source.tar.bz2.part-*` files and run the same script with
`source`. The script checks each reassembled file's expected SHA-256 before
creating the output and refuses to overwrite an existing file. These checksums
detect corruption; they do not authenticate the publisher.

For example, from a new empty directory with GitHub CLI installed:

```sh
gh release download kernel-alpha-0.0.1-lab2 -R Chamath-Adithya/cham-linux \
  --pattern 'kernel.deb.part-*' --pattern 'reassemble-kernel-alpha.py'
python3 reassemble-kernel-alpha.py kernel
```

## Test evidence

- On one LOQ 15ARP9: boot, NVIDIA module load, GPU detection and CUDA memory
  write/readback passed. Short suspend and lid cycles passed on AC, and one
  short lid cycle passed on battery. These are not long-duration tests.
- In a disposable QEMU/OVMF VM: signed kernel booted with Secure Boot enabled,
  the unsigned image was rejected, and a minimal BPF LSM program attached.
  This VM uses a publicly known test key and proves nothing about hardware key
  enrollment or production signing.
- The lab1-to-lab2 package upgrade, initramfs regeneration, GRUB generation,
  package verification and one-shot boot were checked on the LOQ laptop.

## Known limitations and recovery

- The distributed kernel image and NVIDIA modules are unsigned for UEFI Secure
  Boot. **Do not install or boot this package on a Secure Boot enabled system.**
- An unresolved BTF-ID warning concerns an absent `bpf_lsm_inode_xattr_skipcap`
  hook. One VM LSM test does not establish BPF security correctness.
- This laptop logs Lenovo/NVIDIA ACPI firmware errors. BIOS PQCN31WW exists in
  Lenovo's Windows distribution channel, but it has not been installed or
  proven to resolve those errors. The machine's UEFI variable store is nearly
  full; Secure Boot database updates have failed for insufficient space.
- The running Ubuntu fallback in the test setup is pinned to version
  `6.8.0-149`, so installing later Ubuntu updates does not automatically boot
  them. Validate security updates and update that pin promptly.
- This is a manually distributed lab package. Avoid production and other
  hardware; package removal, hardware compatibility, long sleeps, additional
  driver versions and all security configurations have not been fully tested.
  Keep the known-good Ubuntu kernel and GRUB menu available. After booting the
  Ubuntu fallback, remove the lab package with the package manager only when
  recovery is available; never remove the kernel currently in use.

See `docs/CHAM-KERNEL-BUILD.md` for source hashes and the detailed test record.
