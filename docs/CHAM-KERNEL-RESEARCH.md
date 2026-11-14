# Cham Linux kernel research and validation

## Evidence on Lenovo LOQ 15ARP9

- Ubuntu 24.04 HWE `7.0.0-43-generic` with NVIDIA open 580.178.04 entered
  s2idle but did not visibly resume; forced power restart was required.
- Ubuntu 24.04 GA `6.8.0-149-generic` with the same NVIDIA driver completed
  a manual suspend and a lid-close cycle on AC. The user confirmed display,
  keyboard and Wi-Fi after the lid cycle. This is a promising workaround,
  not proof of all workloads, longer sleep durations or battery operation.
- NVIDIA S0ix and preserve-video-memory settings were enabled in both cases.
  The boot journal also reports an ACPI `_DSM` firmware error in both cases;
  its relationship to the suspend failure is not established.
- `linux-generic` is installed to receive supported 6.8 GA package updates.
  The temporary GRUB default explicitly points at 6.8.0-149. New GA kernel
  packages will install through APT, but this fixed GRUB entry will NOT
  automatically move to them. Validate each newer kernel and change the
  default promptly; avoid indefinite use of an outdated booted kernel.

## Candidate engineering approach

1. Preserve the Ubuntu-signed GA kernel as a known-good fallback and retain the
   current NVIDIA DKMS driver. Do not remove kernels or run autoremove while
   they are recovery candidates.
2. Collect reproducible 7.0 failure data and compare Ubuntu kernel and NVIDIA
   packaging revisions. NVIDIA open module issue 1117 describes a similar
   Ubuntu DKMS/7.0 issue, but the affected versions and mechanism differ; it is
   a hypothesis to check, not a diagnosis for this machine.
3. Start from the exact Ubuntu kernel source/config and a distinct localversion
   for any experimental kernel. Keep source, patch series, toolchain versions,
   build logs, hashes and rollback instructions in version control. A third-party
   kernel module or patch must be reviewed and traced to its upstream source.
4. Build in an isolated environment. Validate boot, package upgrade/removal,
   initramfs and rollback in an Ubuntu VM, then test on this laptop with the
   existing kernel available from GRUB. VM success cannot validate laptop
   firmware, NVIDIA display resume or battery behaviour.
5. Measure rather than assume improvement: boot time, idle power, battery,
   temperatures, GPU/CUDA, network, developer workloads and suspend cycles.
   Compare against the same workloads and record regressions.
6. Before promotion, test multiple AC and battery suspend and lid cycles,
   long sleep, external display, audio, Wi-Fi, Bluetooth and real workloads.
   Keep the candidate on an alpha channel until those tests and recovery pass.

Sources: Ubuntu HWE and GA lifecycle documentation at
https://ubuntu.com/kernel/docs/reference/hwe-kernels/ ; NVIDIA driver issue
https://github.com/NVIDIA/open-gpu-kernel-modules/issues/1117 ; Linux kernel
power debugging https://docs.kernel.org/power/basic-pm-debugging.html .
