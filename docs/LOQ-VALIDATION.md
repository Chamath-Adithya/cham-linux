# Lenovo LOQ 15ARP9 validation

Target hardware: Ryzen 7 7435HS (no integrated GPU), RTX 4060 Laptop GPU, MT7921 Wi-Fi and NVMe storage.

Change one power-stack variable at a time. First boot the installed current kernel and keep the current NVIDIA driver. Do not force `deep` sleep when firmware exposes only `s2idle`.

Run at least five cycles for each case: AC suspend/resume, battery suspend/resume, lid close/open, 30-minute sleep, external-display reconnect. After every resume verify the internal display, GNOME session, keyboard, touchpad, audio, Wi-Fi, Bluetooth and NVIDIA status. Review the current boot journal for NVRM Xid, ACPI and resume errors.

Record kernel, NVIDIA driver, firmware, sleep mode, result and journal location. A successful `PM: suspend exit` line alone is not a display-resume pass.
