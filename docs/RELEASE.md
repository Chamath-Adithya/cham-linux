# Release process

1. Create an update branch and explain source, reason and compatibility impact.
2. Build packages in CI and run static/package tests.
3. Install and upgrade in clean Ubuntu VMs; verify removal and rollback.
4. Test the LOQ hardware matrix and record evidence under `reports/` without personal identifiers.
5. Create a release candidate tag such as `v0.1.0-rc.1` after validation.
6. Generate checksums, changelog and provenance. Keep the GitHub release as a draft until validation is complete.
7. Promote the exact tested tag as an immutable release marker. The APT
   workflow is manually dispatched after validation; ordinary pushes do not publish. It builds from the selected ref, which must be reviewed before dispatch and allowed by the GitHub Pages
   deployment environment, signs repository metadata, and deploys it to
   GitHub Pages.

Installed machines receive the next `cham-linux-core` version through the same
`apt update` and `apt upgrade` commands used for Ubuntu updates.

## Update continuity

Ubuntu packages continue to use their configured Ubuntu repositories. Cham
packages use the signed Cham APT archive; Flatpak, Snap and firmware have
separate update mechanisms. The Cham archive does not automatically receive a
new package on every source commit: a maintainer must validate a candidate and
manually dispatch publication. Monitor publication failures and the age of the
last published version; a successful source merge is not proof of a release.

Before publishing, check the installed and archive versions using
`apt-cache policy cham-linux-core` and compare Debian versions with
`dpkg --compare-versions`. The new version must be greater than the published
version and any supported development versions intended to upgrade to it.
For example, a machine with local `0.1.0~alpha12` cannot upgrade from an
archive offering only `0.1.0~alpha8`. Do not overwrite an existing version
with different package bytes. A version change needs testing, release notes,
and the appropriate security and hardware gates before publication.

Manual dispatch currently rebuilds from a selected ref: this does not yet
guarantee promotion of the exact previously tested artifact. Implement and
verify artifact provenance and promotion before describing the channel as a
validated stable release. Report failures promptly; do not disable signature
verification to restore updates.

The existing repository's APT suite is named `stable`, but its current
packages are alpha. A separate validated stable channel has not been released.
Experimental kernel prereleases are separate from this repository and are not
automatically updated through APT.

Security updates can use an expedited candidate cycle but still require package and boot checks. Stable tags and assets are immutable. Published artifacts are never replaced; a correction receives a new version.
