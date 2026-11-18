import plistlib
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]


class CloudKitEnvironmentConfigurationTests(unittest.TestCase):
    def test_build_configurations_select_matching_cloudkit_environments(self) -> None:
        project = (REPOSITORY_ROOT / "project.yml").read_text()

        self.assertIn("ICLOUD_CONTAINER_ENVIRONMENT: Development", project)
        self.assertIn("ICLOUD_CONTAINER_ENVIRONMENT: Production", project)

        with (REPOSITORY_ROOT / "CrestMac/Configuration/Crest.entitlements").open("rb") as entitlements_file:
            entitlements = plistlib.load(entitlements_file)
        self.assertEqual(
            entitlements["com.apple.developer.icloud-container-environment"],
            "$(ICLOUD_CONTAINER_ENVIRONMENT)",
        )

        # Sol ships without CloudKit: the mobile entitlements must stay empty
        # so sideloaded builds never claim a container they cannot reach.
        with (REPOSITORY_ROOT / "CrestMobile/Configuration/CrestMobile.entitlements").open("rb") as entitlements_file:
            mobile_entitlements = plistlib.load(entitlements_file)
        self.assertEqual(mobile_entitlements, {})

    def test_mobile_production_scheme_runs_the_release_configuration(self) -> None:
        scheme_path = (
            REPOSITORY_ROOT
            / "Crest.xcodeproj/xcshareddata/xcschemes/CrestMobile Production.xcscheme"
        )
        scheme = ET.parse(scheme_path).getroot()

        launch_action = scheme.find("LaunchAction")
        self.assertIsNotNone(launch_action)
        self.assertEqual(launch_action.attrib["buildConfiguration"], "Release")

        archive_action = scheme.find("ArchiveAction")
        self.assertIsNotNone(archive_action)
        self.assertEqual(archive_action.attrib["buildConfiguration"], "Release")


if __name__ == "__main__":
    unittest.main()
