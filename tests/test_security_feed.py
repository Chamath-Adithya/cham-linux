#!/usr/bin/env python3
"""Exercise successful and failed feed checks without network access."""
import bz2
import contextlib
import importlib.util
import io
import pathlib
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "check_ubuntu_oval", pathlib.Path(__file__).resolve().parents[1] / "system/check-ubuntu-oval.py"
)
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


class Response(io.BytesIO):
    headers = {"Last-Modified": "test"}


class FeedTests(unittest.TestCase):
    def run_feed(self, payload):
        with patch.object(check.urllib.request, "urlopen", return_value=Response(payload)):
            with contextlib.redirect_stdout(io.StringIO()):
                check.main()

    def test_valid_feed(self):
        xml = (b'<oval_definitions xmlns="http://oval.mitre.org/XMLSchema/oval-definitions-5">'
               b'<definitions><definition /></definitions></oval_definitions>')
        self.run_feed(bz2.compress(xml))

    def test_truncated_feed_fails(self):
        with self.assertRaises(ValueError):
            self.run_feed(bz2.compress(b"<root/>")[:-3])

    def test_wrong_document_fails(self):
        with self.assertRaises(ValueError):
            self.run_feed(bz2.compress(b"<root/>"))

    def test_empty_definitions_fail(self):
        xml = (b'<oval_definitions xmlns="http://oval.mitre.org/XMLSchema/oval-definitions-5">'
               b'<definitions /></oval_definitions>')
        with self.assertRaises(ValueError):
            self.run_feed(bz2.compress(xml))


if __name__ == "__main__":
    unittest.main()
