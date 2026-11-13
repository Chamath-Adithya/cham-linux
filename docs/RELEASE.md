# Release process

1. Create an update branch and explain source, reason and compatibility impact.
2. Build packages in CI and run static/package tests.
3. Install and upgrade in clean Ubuntu VMs; verify removal and rollback.
4. Test the LOQ hardware matrix and record evidence under `reports/` without personal identifiers.
5. Create a release candidate tag such as `v0.1.0-rc.1`.
6. Generate checksums, changelog and provenance. Keep the GitHub release as a draft until validation is complete.
7. Promote the exact tested tag. The APT workflow builds immutable package
   artifacts, signs repository metadata, and deploys it to GitHub Pages.

Installed machines receive the next `cham-linux-core` version through the same
`apt update` and `apt upgrade` commands used for Ubuntu updates.

Security updates can use an expedited candidate cycle but still require package and boot checks. Stable tags and assets are immutable. Published artifacts are never replaced; a correction receives a new version.
