#!/usr/bin/env bash
set -Eeuo pipefail

target=${1:-7.0.0-43-generic}
apply=${2:-}

require_file() {
  [[ -e $1 ]] || { echo "Missing required boot asset: $1" >&2; exit 1; }
}

require_file "/boot/vmlinuz-$target"
require_file "/boot/initrd.img-$target"
modinfo -k "$target" nvidia >/dev/null

root_free_kib=$(df --output=avail / | tail -n 1)
efi_free_kib=$(df --output=avail /boot/efi | tail -n 1)
[[ $root_free_kib -ge 4194304 ]] || { echo 'Less than 4 GiB free on root filesystem.' >&2; exit 1; }
[[ $efi_free_kib -ge 262144 ]] || { echo 'Less than 256 MiB free on EFI partition.' >&2; exit 1; }

printf 'Target kernel: %s\n' "$target"
printf 'NVIDIA module: '; modinfo -k "$target" -F version nvidia
printf 'Root free: %s KiB\nEFI free: %s KiB\n' "$root_free_kib" "$efi_free_kib"
printf 'Fallback kernel: '; readlink -f /boot/vmlinuz.old

if [[ $apply != --apply-grub-safety ]]; then
  echo 'Checks passed. Re-run as root with --apply-grub-safety to set a 10-second GRUB menu.'
  exit 0
fi

[[ $EUID -eq 0 ]] || { echo 'Run the GRUB change as root.' >&2; exit 1; }
backup_dir=/var/backups/cham-linux
install -d -m 0700 "$backup_dir"
backup="$backup_dir/grub-default-$(date +%Y%m%d-%H%M%S)"
cp -a /etc/default/grub "$backup"

sed -i -E 's/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/; s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=10/' /etc/default/grub
update-grub
echo "GRUB safety menu configured. Backup: $backup"
