# Testing status and ways to help

Cham Linux is an early Ubuntu-based Linux distribution project. Its long-term
goal includes maintaining an independent base; that base does not exist yet.
The developer installer remains a prototype, not a production installation ISO.

## Evidence so far

* CI tests package installation, reinstall, removal and an upgrade from a
  synthetic older package in Ubuntu 24.04 containers.
* A separate disposable Ubuntu container upgraded the published Cham
  `0.1.0~alpha8` package to a test package created by changing that package's
  version, with an empty `dpkg --audit`. This exercises upgrade mechanics only;
  it does not validate the contents of a future release.
* A Secure Boot VM reached the installer; inspection of its interrupted virtual
  disk showed Cham core installed. Its first graphical boot remains unverified.
* On the development Lenovo LOQ, Secure Boot was enabled and the NVIDIA driver
  reported the RTX 4060. Suspend after the latest firmware and driver changes
  still needs a controlled physical test.

Recovery and restore, upgrade from actual released versions to a new candidate,
offline installation, first boot, other hardware, and distribution licensing
review are still needed. The current Cham APT suite is named `stable` for
historical reasons but contains alpha software. No stable OS release is claimed.

## Contribute

Please start with [CONTRIBUTING](../CONTRIBUTING.md), use a disposable VM,
and never test the prototype on a disk containing data you need. Useful
contributions include reproducible VM installation reports, accessibility and
documentation improvements, recovery test plans, and original logo proposals
in [the design issue](https://github.com/Chamath-Adithya/cham-linux/issues/4).
Remove private data and identifiers from reports; follow [SECURITY](../SECURITY.md)
for sensitive vulnerabilities. Test results should include software versions,
steps and expected versus actual behavior. We welcome constructive feedback and
will credit contributors according to the project's contribution process.
