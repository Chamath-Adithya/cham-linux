#!/usr/bin/env python3
"""Check that the developer installer keeps storage interaction explicit."""
from pathlib import Path

import yaml

root = Path(__file__).resolve().parent.parent
config = yaml.safe_load((root / "iso/autoinstall.yaml").read_text())
assert set(config) == {"autoinstall"}
install = config["autoinstall"]
assert install["version"] == 1
assert install["interactive-sections"] == ["*"]
assert "storage" not in install
assert "identity" not in install
assert install["late-commands"] == ["sh /cdrom/cham/setup-target.sh"]
print("PASS: developer installer retains all interactive questions and has no preselected storage.")
