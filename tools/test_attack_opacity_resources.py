"""Guard against draw-hook references that compile as unset instance variables."""

import unittest
from pathlib import Path
import tempfile

from check_attack_opacity import ROOT, validate_object_references
from desktop_resources import read_yy


class AttackOpacityResourcesTests(unittest.TestCase):
    def test_fields_comments_and_strings_are_not_object_constants(self):
        self.assertEqual(validate_object_references({"resources": []},
            'global.obj_pool_enabled = false; // obj_comment\nvar label = "obj_text";'), set())

    def test_opacity_and_probe_references_are_registered_in_the_real_project(self):
        project = read_yy(ROOT / "FVM_Reborn_makk.yyp")
        for relative in ("scripts/friendly_attack_visuals/friendly_attack_visuals.gml",
                         "tools/test_attack_opacity.gml"):
            with self.subTest(source=relative):
                validate_object_references(project, (ROOT / relative).read_text())

    def test_existing_object_file_does_not_make_it_a_project_resource(self):
        # Reproduce a real YY file that was never registered in the YYP.
        orphan = "obj_unregistered_effect"
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / f"objects/{orphan}/{orphan}.yy"
            path.parent.mkdir(parents=True)
            path.write_text('{"resourceType":"GMObject"}')
            self.assertTrue(path.is_file())
            with self.assertRaisesRegex(ValueError, orphan):
                validate_object_references({"resources": []}, f"static effects = [{orphan}];")


if __name__ == "__main__":
    unittest.main()
