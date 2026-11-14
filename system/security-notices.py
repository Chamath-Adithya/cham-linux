#!/usr/bin/env python3
"""Find recent Ubuntu notices mentioning a small, declared package inventory."""
import datetime
import json
import pathlib
import sys
import urllib.parse
import urllib.request

ROOT = pathlib.Path(__file__).resolve().parents[1]
URL = "https://ubuntu.com/security/notices.json"
LIMIT = 20
PAGES = 5


def match_notices(inventory, notices):
    names = {package: item["name"] for item in inventory["components"]
             for package in item["ubuntu_packages"]}
    results = []
    for notice in notices:
        packages = notice["release_packages"].get(inventory["release"], [])
        hits = sorted({names[p["name"]] for p in packages if p["name"] in names})
        if hits:
            results.append((notice["id"], notice["title"], notice["published"], hits))
    return results


def main():
    inventory = json.loads((ROOT / "manifests/security-components.json").read_text())
    if inventory["schema"] != 1 or inventory["release"] != "noble" or not inventory["components"]:
        raise ValueError("invalid or unsupported inventory")
    notices = []
    total = None
    for page in range(PAGES):
        params = urllib.parse.urlencode({"release": inventory["release"], "limit": LIMIT, "offset": page * LIMIT})
        with urllib.request.urlopen(f"{URL}?{params}", timeout=45) as response:
            data = json.load(response)
        if data["offset"] != page * LIMIT or data["limit"] != LIMIT or not isinstance(data["notices"], list):
            raise ValueError("unexpected API pagination or response")
        if total is None:
            total = data["total_results"]
        notices.extend(data["notices"])
        if len(notices) >= total:
            break
        if len(data["notices"]) != LIMIT:
            raise ValueError("incomplete API response")
    print("# Recent Ubuntu security notice matches\n")
    print(f"Checked: {datetime.datetime.now(datetime.timezone.utc).isoformat()}  ")
    print(f"Scope: {inventory['scope']}  ")
    print(f"Window: newest {len(notices)} of approximately {total} {inventory['release']} notices.  ")
    print("Matches require maintainer triage. This is not a vulnerability assessment, version comparison, complete SBOM, or indication that a package is installed or vulnerable. Earlier notices and other sources are not covered.\n")
    for notice_id, title, published, hits in match_notices(inventory, notices):
        print(f"- [{notice_id}](https://ubuntu.com/security/notices/{notice_id}): {title} ({published}); components: {', '.join(hits)}")
    print("\nReview exact package versions, Ubuntu backports, source provenance, and applicability before action.")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Security notice report failed: {exc}", file=sys.stderr)
        sys.exit(1)
