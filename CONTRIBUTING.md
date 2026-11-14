# Contributing to Cham Linux

Thank you for helping improve this early-stage project. Useful contributions
include clear bug reports, documentation feedback, accessibility suggestions,
translations, reproducible hardware tests and code review.

## Before you start

- Read [README.md](README.md), [SECURITY.md](SECURITY.md) and the current
  [LICENSE](LICENSE). The license currently reserves rights; contact the owner
  about permission before copying, modifying or redistributing project code.
- Open an issue to discuss substantial changes before investing significant
  time. Small documentation corrections can be proposed directly.
- Use a disposable VM for risky changes. Never test boot, firmware, driver,
  storage or security changes without recovery and a verified backup.

## Good bug reports

Include what you expected, what happened, steps to reproduce, Cham version,
Ubuntu version, desktop session, kernel, hardware model and relevant errors.
Say whether the problem occurs on a clean test system. Please remove names,
user paths, serial numbers, IP addresses, tokens and other private data from
logs and screenshots. Never post passwords, recovery keys or database contents.
Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md).

## Proposing changes

Keep each change focused, describe its purpose and include the checks you ran.
Explain any effects on APT, boot, drivers, personal data or user settings.
Document how to recover from system-level changes. Do not include private keys,
personal backups, generated binaries or credentials in a contribution.

For this repository, run the checks appropriate to your change:

```sh
bash tests/static.sh
make package
git diff --check
```

These checks do not replace clean-VM installation, upgrade, removal, rollback
or physical hardware tests when those are relevant. Please state what was not
tested. Maintainers may ask for additional validation before accepting changes.

## Community

Be patient and constructive. Ask before sharing someone else's information,
and make room for people with different experience levels and languages. See
the [community guidelines](CODE_OF_CONDUCT.md).
