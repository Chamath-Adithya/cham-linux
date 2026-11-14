import importlib.util
import pathlib
import unittest

spec = importlib.util.spec_from_file_location("notices", pathlib.Path(__file__).resolve().parents[1] / "system/security-notices.py")
notices = importlib.util.module_from_spec(spec)
spec.loader.exec_module(notices)


class MatchingTests(unittest.TestCase):
    def test_matches_only_inventory_and_release(self):
        inventory = {"release": "noble", "components": [{"name": "curl", "ubuntu_packages": ["curl", "libcurl4t64"]}]}
        data = [{"id": "USN-1-1", "title": "curl", "published": "2026-01-01", "release_packages": {"noble": [{"name": "curl"}, {"name": "libcurl4t64"}]}},
                {"id": "USN-2-1", "title": "other", "published": "2026-01-01", "release_packages": {"jammy": [{"name": "curl"}]}}]
        self.assertEqual(notices.match_notices(inventory, data), [("USN-1-1", "curl", "2026-01-01", ["curl"])])

    def test_missing_required_fields_fails(self):
        with self.assertRaises(KeyError):
            notices.match_notices({"release": "noble", "components": []}, [{}])


if __name__ == "__main__":
    unittest.main()
