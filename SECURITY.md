# Security policy

Do not open a public issue containing secrets, personal logs, serial numbers, recovery keys, or an unpatched vulnerability. Send a private GitHub security advisory to the repository owner.

Release artifacts must be built by GitHub Actions or the documented local build, accompanied by SHA-256 checksums, and promoted only after clean-VM and physical-hardware validation. Signing credentials must never be committed to this repository or exposed to pull-request jobs.
