# Lenovo LOQ firmware investigation — 2026-11-14

Machine: Lenovo LOQ 15ARP9 (83JC), BIOS PQCN27WW dated 2026-01-07.
LVFS metadata was refreshed and fwupd reported no System Firmware update for
this machine. Lenovo's official support page separately lists PQCN31WW for
LOQ 15ARP9, released 2026-08-12, using a Windows 11 installer. Lenovo describes
security updates for CVE-2026-6726 and CVE-2026-6727, but does not list a fix
for the NVIDIA ACPI `PEGP.GPS.NVD1` error. Do not assume this update resolves
the NVRAM capacity or ACPI issues without measurement and testing.

The Lenovo Windows installer was downloaded to
`~/Downloads/Cham-Firmware/pqcn31ww.exe` and its SHA-256 was checked against
Lenovo's published value:
`7a61a6661932796ec4b3a9f85a83b0b1d12fca7a7ef06830005e33e671133706`.
It has not been executed or flashed. This Linux download may not be visible
from Windows; download directly from Lenovo there if required. Establish the
Windows recovery-key status and model-specific recovery path before flashing.

The machine has separate Ubuntu and Windows Boot Manager entries. Secure Boot
is disabled. `lsblk` identifies the large Windows partition as BitLocker; its
recovery key and Windows protection status have not been verified. Firmware or
Secure Boot changes may require the Windows recovery key. Consult Microsoft's
BitLocker firmware-update guidance and resume protection afterwards:
https://learn.microsoft.com/en-us/troubleshoot/windows-client/windows-security/suspend-bitlocker-protection-non-Microsoft-updates

`efivarfs` reports approximately 148 KiB total and 6.5 KiB
available; this is a firmware variable store, not the EFI disk partition.
fwupd reports that the UEFI CA and dbx updates previously failed for lack of
space, with requests of 16.4 KiB and 30.7 KiB respectively. The reported
free-space figures can differ between fwupd's historical error and a current
filesystem measurement. Large variables include current and factory-default
dbx, db and KEK databases. Their presence alone is not proof that deleting any
of them is safe. No UEFI variables or boot entries were removed.

The fwupd project documents firmware-specific handling of dbx/efivarfs
failures and recommends checking manufacturer firmware or contacting the OEM:
https://github.com/fwupd/fwupd/wiki/LVFS-Triaged-Issue:-dbx-efivarfs-IO-error
A similar NVRAM capacity report on another Lenovo device is at
https://github.com/fwupd/fwupd/issues/10635. Do not assume its solution applies
to this model. The Lenovo support page is
https://support.lenovo.com/aw/en/downloads/ds568585-bios-update-for-windows-11-64-bit-loq-15arp9

Local diagnostic snapshots were saved under
`~/.local/state/cham-linux/firmware-diagnostics/` with private permissions.
The device inventory can include serial numbers: review it before sharing.
The boot-entry snapshot is descriptive, not a bootable recovery medium.

Secure Boot candidate boot and unsigned rejection were tested in a disposable
OVMF VM using public test keys, not on this laptop. Hardware testing still
requires a signed image, an appropriately managed machine-owner key, enough
firmware storage, and verified recovery for both operating systems. An existing
module-only MOK must not be assumed to authorize boot images. Avoid bypassing
fwupd's free-space check, resetting keys or deleting EFI variables without a
device-specific recovery procedure.
