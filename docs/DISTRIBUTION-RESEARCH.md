# Distribution research and update automation

Research snapshot: 2026-11-15. Design proposals below are not shipped features,
and apparent user problems are hypotheses until validated with interviews and
hardware reports. Compare actual workflows and supported hardware before
claiming superiority over any distribution.

| System | Useful approach | Trade-off / Cham opportunity |
| --- | --- | --- |
| Ubuntu | LTS maintenance, signed packages, phased updates | Phasing helps reduce exposure to regressions but means an update may be delayed. Explain the reason and security status; do not bypass phasing indiscriminately. [1] |
| Kali | Focused security tool distribution | Adding Kali repositories to Ubuntu can break the host. Offer an optional isolated environment with its own updates, making its boundaries clear. [2] |
| Arch | Rolling releases and extensive documentation | Partial upgrades are unsupported. Treat an Arch environment as an independently managed system, rather than importing selected binaries into the host. [3] |
| Fedora Silverblue | Image-based operating system, previous deployments and rollback | Host modifications have a different workflow and rollback needs available deployment storage. Prototype recovery in a VM first; do not claim existing Cham installs support it. [4] |
| openSUSE transactional systems | Snapshot-based transactional updates | This model depends on filesystem, snapshot and reboot integration. Test recovery and disk-full behavior before proposing a migration. [5] |
| NixOS | Declarative configuration and generations | Retained generations consume storage and boot space. A friendly configuration history could borrow the concept without claiming NixOS semantics. [6] |
| Qubes OS | Isolation of tasks using virtual machines | Strong compartmentalization has hardware and resource requirements; a simple container does not provide equivalent isolation. Offer a clear, optional threat-model choice. [7] |
| Tails | Temporary sessions designed to reduce persistent traces | Its security goals and workflow differ from an everyday workstation; persistent configuration and external risks remain separate concerns. A disposable session would require its own threat model and validation. [8] |

## Cham concepts to test with people

1. **Update provenance timeline**: each source, pending version, result, reboot
   and retry explanation, with a preview before changes. Integrate native APT,
   Flatpak and firmware mechanisms; isolated guests have their own lifecycle.
2. **Hardware passport**: consent-based local evidence tied to exact laptop,
   firmware, kernel and GPU driver. Display untested combinations as unknown,
   including suspend on AC and battery; avoid treating one success as universal.
3. **Recovery rehearsal**: encrypted backup destination, last successful backup
   and independently verified restore date. Explore rollback in a disposable VM;
   snapshots do not protect against drive loss or replace external backups.
4. **Local explanation**: on-demand diagnostics and optional small-model
   explanation; show evidence, make collection/training opt-in, and require user
   approval before a repair. Never let the model directly administer the system.
5. **Transparent environments**: desktop shortcuts for optional Kali/Arch tool
   environments with storage and update status. Containers share the host kernel;
   use a VM when the security boundary actually requires one.

## Security automation design

Existing upstream-watch opens a weekly version-discovery issue for selected
projects; Dependabot tracks GitHub Actions versions. Neither monitors every
component or automatically applies security fixes. Existing release and APT
publication workflows need their own audit before any expansion of permissions.

1. Maintain a versioned component inventory: name, source, license, build recipe,
   owning maintainer, supported versions, advisory feeds and whether Cham modifies
   it. A complete SBOM must include build and runtime dependencies and images.
2. Collect upstream advisories and releases on a schedule. For Ubuntu packages,
   use Canonical's OVAL/USN data and distro-specific version semantics, including
   backports. An unavailable, stale or unparsable feed is a visible failure,
   never a clean bill of health. Other distributions require their own feeds.
3. Deduplicate by advisory and affected component; record a triage owner, status,
   affected versions, fix and target date. CVE matches can be false positives or
   miss unreported vulnerabilities; use human review and reconcile exceptions.
4. Generate candidate changes in an isolated build environment from authenticated
   sources. Verify signatures and provenance, pin dependencies, retain logs and
   artifacts, and never run untrusted pull-request code with publishing secrets.
5. Test package installation, upgrades, dependencies and removal in clean VMs,
   then boot, network, graphics and rollback. Kernel or NVIDIA candidates also
   require Secure Boot and real hardware/suspend evidence for supported devices.
6. Sign and promote a tested alpha artifact first. Promote the exact same
   artifact to stable only after documented gates and maintainer review. Keep
   signing keys separated from ordinary CI and provide a revocation procedure.
7. Monitor releases, failed jobs and advisory age; document a security contact,
   response ownership, escalation and rollback. Emergency patches need an
   explicit expedited route, not indefinite waiting for a weekly report.

This is an engineering plan, not an implemented end-to-end pipeline. Signed
Ubuntu packages continue to receive updates from their configured Ubuntu sources;
forked Cham components become Cham's own maintenance responsibility. No process
can guarantee zero conflicts or catch every vulnerability.

## Sources

1. https://documentation.ubuntu.com/project/how-ubuntu-is-made/concepts/phased-updates/
2. https://www.kali.org/docs/general-use/kali-apt-sources/
3. https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported
4. https://docs.fedoraproject.org/en-US/fedora-silverblue/updates-upgrades-rollbacks/
5. https://documentation.suse.com/sle-micro/6.1/html/Micro-transactional-updates/index.html
6. https://nixos.org/manual/nixos/stable/
7. https://www.qubes-os.org/doc/system-requirements/
8. https://tails.net/doc/about/introduction/
9. https://ubuntu.com/security/oval
10. https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-security-updates
