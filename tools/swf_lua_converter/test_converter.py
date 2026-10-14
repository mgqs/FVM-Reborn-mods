import ctypes
import json
import struct
import tempfile
import unittest
import zlib
from pathlib import Path

from core import Unsupported, abc_inventory, archive_swf, transpile, validate_lua, convert_session, digest
from card_analysis import analyze_card

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent


class StrictConversionTests(unittest.TestCase):
    def test_unknown_card_rejects_and_removes_stale_lua(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            source = 'package p { public class Entry extends UnknownBase {} }'
            (out / 'entry.as').write_text(source, encoding='utf-8')
            (out / 'original.swf').write_bytes(b'archived-test')
            (out / 'logic.lua').write_text('old success', encoding='utf-8')
            report = {'status': 'extracted', 'errors': [], 'lua_emitted': False}
            record = {'file': 'entry.as', 'sha256': digest(source.encode()), 'classes': ['p.Entry'],
                      'imports': [], 'base_classes': ['UnknownBase'], 'conversion': 'unconverted'}
            (out / 'report.json').write_text(json.dumps(report), encoding='utf-8')
            (out / 'scripts_inventory.json').write_text(json.dumps({'files': [record]}), encoding='utf-8')
            (out / 'swf_inventory.json').write_text(json.dumps({'sha256': digest(b'archived-test'), 'blockers': []}), encoding='utf-8')
            with self.assertRaises(Unsupported): convert_session(out, 'unused.dll')
            self.assertFalse((out / 'logic.lua').exists())
            self.assertEqual(json.loads((out / 'report.json').read_text(encoding='utf-8'))['status'], 'conversion_blocked')

    def test_dependency_graph_accounts_for_every_file(self):
        records = [
            {'file': 'entry.as', 'classes': ['p.Entry'], 'imports': ['p.Base'], 'base_classes': ['Base']},
            {'file': 'base.as', 'classes': ['p.Base'], 'imports': ['p.Helper'], 'base_classes': []},
            {'file': 'helper.as', 'classes': ['p.Helper'], 'imports': ['outside.Engine'], 'base_classes': []},
            {'file': 'ui.as', 'classes': ['p.UI'], 'imports': [], 'base_classes': []},
        ]
        sources = {'entry.as': 'class Entry extends Base {}', 'base.as': 'class Base {}',
                   'helper.as': 'class Helper {}', 'ui.as': 'class UI {}'}
        analysis = analyze_card(records, sources, 'p.Entry')
        self.assertEqual(analysis['reachable_classes'], ['p.Base', 'p.Entry', 'p.Helper'])
        self.assertEqual(analysis['external_dependencies'], {'p.Helper': ['outside.Engine']})
        self.assertEqual(len(analysis['files']), 4)
        self.assertEqual(analysis['files'][-1]['classification'], 'excluded')
        self.assertTrue(analysis['files'][-1]['reason'])
        with self.assertRaises(ValueError): analyze_card(records, sources, 'missing.Entry')

    def test_adapted_three_row_bursts_and_edge_rows(self):
        lua = (HERE / 'adapters/termi_three_shot_gun.lua').read_text(encoding='utf-8')
        dll = ROOT / 'datafiles/native/FvmNativeSupport.dll'
        lib = ctypes.CDLL(str(dll))
        create, call, destroy = lib.ModLuaCreate, lib.ModLuaCall, lib.ModLuaDestroy
        create.argtypes, create.restype = [ctypes.c_char_p], ctypes.c_char_p
        call.argtypes, call.restype = [ctypes.c_double, ctypes.c_char_p, ctypes.c_char_p], ctypes.c_char_p
        destroy.argtypes, destroy.restype = [ctypes.c_double], ctypes.c_double
        for row, expected_rows in [(2, [3, 1, 2]), (0, [1, 0]), (4, [3, 4])]:
            handle = json.loads(create(lua.encode()))['handle']
            try:
                ctx = {'id': 1, 'row': row, 'rows': 5, 'row_height': 116, 'dt': 1/60,
                       'cycle': 78, 'atk': 52, 'params': {'grade': 1},
                       'enemies': [{'id': 50, 'hp': 100, 'row': row + (1 if row < 4 else -1)}]}
                def invoke(event):
                    result = json.loads(call(handle, event.encode(), json.dumps(ctx).encode()))
                    self.assertTrue(result['ok'], result)
                    return result['commands']
                invoke('on_create')
                bursts = []
                for tick in range(1, 111):
                    shots = [c for c in invoke('on_step') if c['op'] == 'shoot']
                    if shots: bursts.append((tick, shots))
                self.assertEqual([t for t, _ in bursts], [102, 108])
                for _, shots in bursts:
                    self.assertEqual([row + c['row_offset'] for c in shots], expected_rows)
                    for command in shots:
                        self.assertEqual(command['damage'], 52)
                        self.assertEqual(command['burn']['duration'], 21)
                        self.assertEqual(command['burn']['power'], 13)
                        self.assertEqual(command['speed'], 10/3)
                        self.assertEqual(command['speed_y'], command['row_offset'] * 20/3)
                        self.assertGreaterEqual(command['burn']['roll'], 0)
                        self.assertLessEqual(command['burn']['roll'], 100)
                ctx['enemies'] = []
                for _ in range(120): self.assertFalse([c for c in invoke('on_step') if c['op'] == 'shoot'])
            finally: destroy(handle)

    def test_real_game_dll_and_callback_timing(self):
        lua = transpile((HERE / '示例行为.as').read_text(encoding='utf-8'))
        dll = ROOT / 'datafiles/native/FvmNativeSupport.dll'
        self.assertEqual(validate_lua(lua, dll)['syntax_and_initialization'], 'passed')
        lib = ctypes.CDLL(str(dll))
        create, call, destroy = lib.ModLuaCreate, lib.ModLuaCall, lib.ModLuaDestroy
        create.argtypes, create.restype = [ctypes.c_char_p], ctypes.c_char_p
        call.argtypes, call.restype = [ctypes.c_double, ctypes.c_char_p, ctypes.c_char_p], ctypes.c_char_p
        destroy.argtypes, destroy.restype = [ctypes.c_double], ctypes.c_double
        handle = json.loads(create(lua.encode()))['handle']
        try:
            ctx = json.dumps({'cycle': 120, 'atk': 52}).encode()
            self.assertTrue(json.loads(call(handle, b'on_create', ctx))['ok'])
            shots = []
            for tick in range(1, 361):
                result = json.loads(call(handle, b'on_step', ctx))
                self.assertTrue(result['ok'], result)
                if result['commands']: shots.append((tick, result['commands']))
            self.assertEqual([t for t, _ in shots], [120, 240, 360])
            for _, commands in shots:
                self.assertEqual(commands, [{'op': 'shoot', 'sprite': 'ice', 'damage': 52,
                                             'speed': 8, 'slow_ticks': 180}])
        finally: destroy(handle)

    def test_fail_closed_unknown_script_and_dependencies(self):
        demo = (HERE / '示例行为.as').read_text(encoding='utf-8')
        for invalid in [demo.replace('state.ticks = 0;', 'unknownFlashCall();', 1),
                        demo.replace('public class SimpleCard', 'public class SimpleCard extends DefenderBase'),
                        demo.replace('state.ticks + 1', 'state.ticks % 2'),
                        demo.replace('damage:ctx.atk', 'damage:"wrong"'),
                        demo.replace('state.ticks + 1', 'state.ticks + "1"'),
                        demo.replace('state.ticks >= ctx.cycle', 'state.ticks'),
                        demo + 'ignoredCode();']:
            with self.subTest(invalid=invalid):
                with self.assertRaises(Unsupported): transpile(invalid)

    def test_all_tags_preserved_and_truncation_rejected(self):
        def tag(code, payload):
            n = len(payload)
            return struct.pack('<H', (code << 6) | min(n, 63)) + (struct.pack('<I', n) if n >= 63 else b'') + payload
        sprite = struct.pack('<HH', 1, 1) + tag(12, b'\0') + tag(0, b'')
        body = b'\x08\x00' + struct.pack('<HH', 60 * 256, 1) + tag(39, sprite) + tag(0, b'')
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            for compressed in (False, True):
                out = base / str(compressed); out.mkdir()
                raw = (b'CWS' if compressed else b'FWS') + b'\x0a' + struct.pack('<I', len(body) + 8) + (zlib.compress(body) if compressed else body)
                source = base / 'test.swf'; source.write_bytes(raw)
                inventory = archive_swf(source, out)
                self.assertEqual(len(inventory['tags']), 4)
                self.assertTrue(inventory['blockers'])
                self.assertEqual((out / 'original.swf').read_bytes(), raw)
                self.assertEqual(len(list((out / 'raw_tags').glob('*_tag_*.bin'))), 4)
            out = base / 'bad'; out.mkdir(); source.write_bytes(raw[:-1])
            with self.assertRaises(Unsupported): archive_swf(source, out)

    def test_abc_initializers_and_method_bodies_are_counted(self):
        # Minimal ABC: no constants, one method, one script initializer, one method body.
        abc = struct.pack('<HH', 16, 46) + b'\x01' * 7
        abc += b'\x01\x00\x00\x00\x00'  # method count; parameters, return, name, flags
        abc += b'\x00\x00'  # metadata / classes
        abc += b'\x01\x00\x00'  # scripts=1, init=0, traits=0
        abc += b'\x01\x00\x01\x01\x00\x01\x01\x47\x00\x00'
        info = abc_inventory(abc)
        self.assertEqual(info['script_count'], 1)
        self.assertEqual(info['method_count'], 1)
        self.assertEqual(info['bodies'][0]['code_size'], 1)
        with self.assertRaises(Unsupported): abc_inventory(abc + b'\0')
        with self.assertRaises(Unsupported): abc_inventory(abc[:-1])


if __name__ == '__main__': unittest.main()
