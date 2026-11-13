# Kernel update validation

Cham Linux uses the Ubuntu HWE kernel and does not ship unreviewed AI-generated
kernel patches. A kernel or driver update must first pass the pre-reboot check:

```bash
./system/prepare-kernel-reboot.sh 7.0.0-43-generic
```

The check verifies the kernel image, initramfs, NVIDIA module, fallback kernel,
and free root/EFI space. To make recovery selection easier, apply a 10-second
GRUB menu after reviewing the check:

```bash
sudo ./system/prepare-kernel-reboot.sh 7.0.0-43-generic --apply-grub-safety
```

If the new kernel fails to display or resume, restart the laptop and select:

`Advanced options for Ubuntu` → `Ubuntu, with Linux 7.0.0-42-generic`

Then collect `cham ai report`, do not delete either kernel, and investigate the
specific regression before testing another candidate. A custom kernel requires
a separate test build, rollback boot entry, and GPU, Wi-Fi, suspend, filesystem,
and battery validation.
