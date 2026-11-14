# Security notice triage (initial, limited scope)

`manifests/security-components.json` lists selected direct dependencies and
recommendations of cham-linux-core, with upstream links and Ubuntu package
names. It is manually curated, not an SBOM or a list of packages on a laptop.
Update it with package dependency changes and review aliases against Ubuntu.

The daily GitHub Actions report queries the newest 100 Noble USNs and matches
package names. Open the workflow run summary to review results and failures.
It does not open issues or install packages. The report can miss older notices,
new notices exceeding its window, unpublished fixes, other distributions,
packages not in the inventory, transitive dependencies, and non-Ubuntu builds.
API failures fail the workflow; they are not evidence of a clean system.

For each match, a maintainer should check the notice, actual installed and
candidate versions, package origin, Ubuntu backports, release and support
status. Record applicability, owner and remediation. For Cham-maintained forks,
review source changes and build/test a candidate. For Ubuntu-supplied packages,
follow Ubuntu's security update process. Escalate privately as described in
SECURITY.md if the information is not already public. A notice match alone does
not establish that any device is vulnerable or that a fix is available.

This report does not replace a full SBOM, OVAL/OSV evaluator, security team,
continuous monitoring, package build infrastructure or a release gate. The
repository's APT signing workflow already exists; it currently publishes builds
from main and is not a validated stable promotion system.
