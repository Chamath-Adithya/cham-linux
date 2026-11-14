# Experimental Cham kernel baseline

This is a VM-only build experiment, not a production or laptop kernel.
The host must continue using the Ubuntu 6.8.0-149 kernel while the 7.0
suspend regression is investigated. Do not install the generated image.

- Source: Ubuntu `linux-source-6.8.0` package `6.8.0-149.149`.
- Source tarball SHA-256: `6aae16a368cc24fe1a6132bf4a012c55c4b3f8bd8c77aca4523937da1b1e3ad4`.
- Starting configuration: `/boot/config-6.8.0-149-generic`, SHA-256
  `1addff02f85a47fb16c401618d47523421c655e9b458f675d07d9f61b7b26753`.
- Test kernel release: `6.8.12-cham-vmtest`. The 6.8.12 upstream version is
  from Ubuntu's source Makefile; the Ubuntu package revision is 149.149.
- Ubuntu's binary source tarball does not include Canonical build certificates.
  The VM test configuration sets trusted/revocation certificate paths empty.
  This changes trust semantics; this image is not signed, not production
  equivalent, and unsuitable for host installation or security evaluation.
- `system/build-cham-kernel-vm.sh` uses one job and writes only under
  `build/kernel-6.8.0-149`. It does not install packages or modify GRUB.
- `system/test-cham-kernel-vm.sh` boots only a tiny disposable initramfs under
  QEMU TCG with no real disk attached. It verifies boot-to-userspace only;
  it does not test the laptop GPU, suspend, Wi-Fi or battery.

## Baseline result (2026-11-14)

`bzImage` built successfully and SHA-256 was
`33fe81a94d601692278661ef1a196f461047d3f9fe68ad0d70873b44705356c8`.
The QEMU smoke test printed `CHAM_VM_BOOT_OK` and `6.8.12-cham-vmtest`.
Linking reported unresolved BTF IDs for `bpf_lsm_task_getsecid_obj`,
`bpf_lsm_current_getsecid_subj` and `bpf_lsm_inode_xattr_skipcap`.
Upstream has a change concerning the first two IDs; verify source history and
the third warning before proposing a patch. Do not suppress the warnings or
assume the upstream commit applies unchanged to Ubuntu's backported source.
The build increased swap use to about 3.8 GiB despite a one-job compile. The
image remains VM-only. No host image, modules, initramfs, or GRUB entry changed.

## Upstream patch experiment

Applied upstream commit `8618f5ffba4d381610f6bb4c472a6148c2bfde96` to the
disposable source copy; the reviewable patch is in `kernel/patches/`. The two
getsecid BTF warnings disappeared. `bpf_lsm_inode_xattr_skipcap` remains
unresolved and is not blindly removed. The patched image SHA-256 is
`d32e30deabc21a3ca58916b067de3ed29ff5ae72d804c07a0f85120719ffc521`.
It passed the same QEMU initramfs boot smoke test; the original image is kept
separately as `build/kernel-6.8.0-149/bzImage-baseline`. A boot test is not a
security, performance, DKMS, suspend or hardware validation.

## Lab candidate (2026-11-14)

The separate `6.8.12-cham-lab1` candidate was built from the patched source
and the Ubuntu configuration, using the public trust and revocation bundles
from the matching Ubuntu buildinfo package. Its image SHA-256 is
`ea4d99c127da722c323bebafd5c9981b946ed418041076e91c66715ab4f7671f`.
`bash system/test-cham-kernel-vm.sh candidate` booted the isolated QEMU
initramfs and reported that release. This image is not signed for Secure Boot.
Keep the generated private module-signing key private; never publish the build
directory or its key.

An isolated NVIDIA 580.178.04 source build produced all five modules with
candidate-matching vermagic. The build emitted compiler warnings, including
missing prototypes; its log is in the ignored build directory. No module was
installed or loaded, and this is not evidence that the GPU or resume works.
The previously observed `bpf_lsm_inode_xattr_skipcap` BTF warning remains a
release investigation item. Packaging, signing, GPU, suspend, lid, Wi-Fi,
rollback and repeated laptop testing remain prerequisites for a release.

On a later staging run, `modules_install` placed 6,472 built-in-tree modules
in a private build staging directory and five separately built NVIDIA modules
were added there. `depmod` completed and `modprobe --show-depends` resolved
the staged NVIDIA DRM dependency chain. This is a dependency simulation: it
does not load a module or establish GPU compatibility. The staged NVIDIA
modules have no module signature. No system modules or boot files were changed.
`bash system/check-cham-kernel-gpu.sh` checks the running kernel version and
basic NVIDIA module/device visibility after a future candidate boot; it does
not perform a rendering, compute, or suspend test.

The running Ubuntu 6.8.0-149 kernel passed a small CUDA allocation, device
memory write, synchronization and readback on the RTX 4060. The repeatable
`system/check-cham-kernel-cuda.py` defaults to requiring the candidate kernel;
passing another expected release establishes a baseline only. This does not
establish that the candidate works with the GPU.

## Initial Lenovo LOQ test (2026-11-14)

The local-only lab package was installed, leaving the Ubuntu 6.8.0-149 GRUB
default unchanged; the candidate was selected for one boot. On this laptop,
`6.8.12-cham-lab1` booted with the NVIDIA 580.178.04 modules loaded, and the
16 MiB CUDA memory write/readback passed before and after one short s2idle
suspend. The user confirmed the screen resumed after a keypress. The journal
recorded suspend entry and exit and successful NVIDIA suspend/resume services;
Wi-Fi remained connected. Firmware ACPI errors and other kernel warnings were
still logged. This single short test is not a stability or release validation.
The default after the one-shot boot remains the tested Ubuntu kernel.

The user subsequently closed and reopened the lid and confirmed that the
display, keyboard and Wi-Fi worked. The journal recorded another s2idle entry
and exit, and NVIDIA suspend/resume services completed. The NVIDIA visibility
and CUDA memory readback checks passed again after the lid test. These two
short tests on this laptop do not establish long-duration, battery, other-device
or Secure Boot compatibility.

An improved local lab package `0.0.1~lab2` was built with readable module
files. The package listing contains no private signing key or build/source
symlinks. A simulated APT upgrade reported no removals, and an actual local
upgrade from lab1 to lab2 completed with initramfs and GRUB regeneration.
`dpkg --verify` reported no differences; NVIDIA and CUDA checks still passed.
A subsequent one-shot boot on 2026-11-14 loaded the lab2 initramfs and
candidate kernel successfully; NVIDIA module visibility, CUDA memory readback,
Wi-Fi connectivity, and `dpkg --verify` passed after boot. The journal still
reported the previously observed NVIDIA-related ACPI firmware errors. The
kernel image remains the same as lab1, and Ubuntu 6.8 remains the GRUB default.
`system/check-kernel-lab-package.py` also streamed the lab2 archive and
verified the expected image hash, presence and read permissions of all five
NVIDIA modules, and absence of signing material and build/source links.
After this reboot the user reported a successful battery-powered lid-close
test, including display, keyboard and Wi-Fi. The journal recorded s2idle from
12:21:13 to 12:22:09 and successful NVIDIA suspend/resume services; NVIDIA,
CUDA memory readback and connected Wi-Fi were verified after wake. AC was
connected again by the time the checks ran. This is one short battery cycle.

## Signing and BTF investigation

`system/test-kernel-signing.py` uses an ephemeral key to sign and verify a
copy of the candidate EFI image and sign a copy of an NVIDIA module. This
checks local signing tools only: the temporary key is deleted and is not
enrolled, the installed image is unchanged, and Secure Boot remains disabled.
The existing system MOK certificate is marked for module signing; do not
assume it can sign a bootable kernel. Signing key custody, enrollment, signed
release artifacts and a Secure Boot hardware test remain open.

On 2026-11-14 the separate `system/test-kernel-secureboot-vm.sh` test booted
the candidate through shim and GRUB with Secure Boot enabled in OVMF, using
OVMF's publicly distributed snakeoil test key. The VM reported SecureBoot=1,
enabled the BPF LSM, and loaded and attached a minimal `file_open` LSM program.
The `unsigned` negative-control run rejected the unsigned candidate with
`bad shim signature`. This test key is public and must never be used for a
real machine or release. A single test hook does not validate the missing
`inode_xattr_skipcap` entry or the complete security verifier.

The laptop itself remains in Secure Boot disabled mode. Its efivarfs reported
96% used with about 6.5 KiB available; fwupd reports prior failed UEFI CA and
dbx updates due to insufficient variable storage. Do not delete firmware
variables or enroll keys blindly: the system also has a Windows boot entry.
Resolve firmware variable capacity and prepare verified recovery and key
custody before attempting hardware enrollment and a Secure Boot test.

In this source snapshot `bpf_lsm_inode_xattr_skipcap` appears in the boolean
LSM hook BTF-ID list, but no hook definition was found by source search.
Using the Ubuntu 6.8 bpftool binary directly against the running candidate's
BTF shows `bpf_lsm_inode_getxattr` and `bpf_lsm_inode_setxattr`, but no
`bpf_lsm_inode_xattr_skipcap` function. This is evidence of a dangling BTF-ID
reference, not proof that deleting it is safe for every BPF security case.
Do not silence or remove it for a release without source/backport review and
BPF security tests. The usual `/usr/sbin/bpftool` version-selection wrapper
also does not find tools for the custom release; use the matching Ubuntu
binary explicitly for inspection, and solve custom kernel tooling packaging.
Although `CONFIG_BPF_LSM=y`, the current active LSM list is
`lockdown,capability,landlock,yama,apparmor`: BPF LSM is not active in this
boot. Consequently the laptop tests did not validate BPF LSM behaviour.

The current boot selection is explicitly pinned to `6.8.0-149`. The
`linux-generic` metapackage downloads later GA versions but does not change
that selection automatically. Validate and switch to newer security updates;
never assume an installed newer kernel is running. Keep the 7.0 kernel and
known-good 6.8 entry for recovery. Do not run automatic kernel autoremove.
