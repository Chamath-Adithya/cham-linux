#!/usr/bin/env python3
"""Check the Ubuntu Noble USN feed can be downloaded and parsed, not CVE status."""
import bz2
import datetime
import sys
import urllib.request
import xml.etree.ElementTree as ET

URL = "https://security-metadata.canonical.com/oval/com.ubuntu.noble.usn.oval.xml.bz2"
MAX_COMPRESSED = 20 * 1024 * 1024
MAX_XML = 150 * 1024 * 1024


def main():
    with urllib.request.urlopen(URL, timeout=45) as response:
        compressed = response.read(MAX_COMPRESSED + 1)
        modified = response.headers.get("Last-Modified", "not provided")
    if len(compressed) > MAX_COMPRESSED:
        raise ValueError("compressed feed exceeds size limit")
    decompressor = bz2.BZ2Decompressor()
    xml = decompressor.decompress(compressed, max_length=MAX_XML + 1)
    if len(xml) > MAX_XML or not decompressor.eof:
        raise ValueError("feed is truncated or exceeds XML size limit")
    root = ET.fromstring(xml)
    if root.tag != "{http://oval.mitre.org/XMLSchema/oval-definitions-5}oval_definitions":
        raise ValueError("unexpected OVAL root element")
    definitions = root.find("{http://oval.mitre.org/XMLSchema/oval-definitions-5}definitions")
    count = len(definitions) if definitions is not None else 0
    if not count:
        raise ValueError("no definitions in OVAL feed")
    print(f"Checked: {datetime.datetime.now(datetime.timezone.utc).isoformat()}")
    print(f"Source: {URL}\nLast-Modified: {modified}\nDefinitions: {count}")
    print("Feed availability and XML only; installed packages and CVEs were not assessed.")


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"OVAL feed check failed: {exc}", file=sys.stderr)
        sys.exit(1)
