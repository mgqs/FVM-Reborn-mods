#!/usr/bin/env python3
"""Differential targeting and DS lifetime checks in a disposable GameMaker VM app."""
import copy
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import zipfile

import build_macos
from desktop_resources import read_yy

ROOT = Path(__file__).resolve().parents[1]


def check():
    work = ROOT / '.macos-build/combat-targets-check'
    source = work / 'source'
    if source.exists():
        shutil.rmtree(source)
    source.mkdir(parents=True)
    project = copy.deepcopy(read_yy(ROOT / 'FVM_Reborn_makk.yyp'))
    project.update(name='FVMCombatTargetsCheck', **{'%Name': 'FVMCombatTargetsCheck'},
                   resources=[], IncludedFiles=[], Folders=[], RoomOrderNodes=[])
    group = copy.deepcopy(project['TextureGroups'][0])
    group.update(name='Default', **{'%Name': 'Default'}, loadType='default', compressFormat='bz2', customOptions='')
    group.pop('ConfigValues', None)
    project['TextureGroups'] = [group]
    shutil.copytree(ROOT / 'options', source / 'options')

    def write(path, data):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')

    def resource(kind, name, data):
        relative = f'{kind}/{name}/{name}.yy'
        data.update(name=name, **{'%Name': name}, parent=None)
        write(source / relative, data)
        project['resources'].append({'id': {'name': name, 'path': relative}})
        return (source / relative).parent

    template = read_yy(ROOT / 'scripts/combat_targets/combat_targets.yy')
    for name in ('combat_targets', 'can_target_on', 'get_grid_position_from_world',
                 'mod_build_buff_grid', 'mod_build_buff_shield', 'mod_build_buff_aurora'):
        path = resource('scripts', name, copy.deepcopy(template))
        (path / f'{name}.gml').write_text((ROOT / f'scripts/{name}/{name}.gml').read_text())
    probes = (ROOT / 'tools/test_combat_targets.gml').read_text()
    # Compile the actual migrated query statements too, so call-site parameters
    # (especially three-row bounds) are covered alongside helper correctness.
    teleport = (ROOT / 'objects/obj_wanpilong/Step_0.gml').read_text()
    row_write = re.search(r'_entity\.grid_row = [^;]+;', teleport).group()
    probes += '\nfunction combat_probe_teleport_row(_entity, _to_row) { ' + row_write + ' }\n'
    platform = (ROOT / 'objects/obj_platform/Step_2.gml').read_text()
    row_write = re.search(r'plant\.grid_row = [^;]+;', platform).group()
    probes += '\nfunction combat_probe_platform_row(plant, target_r) { ' + row_write + ' }\n'
    calls = []
    for path in sorted((ROOT / 'objects').glob('*/Step_0.gml')):
        text = path.read_text(encoding='utf-8-sig')
        match = re.search(r'has_enemy = (combat_enemy_in_rows\([^;]+\));', text)
        nearest = re.search(r'target_enemy = (combat_enemy_nearest_in_row\([^;]+\));', text)
        if not (match or nearest):
            continue
        name = path.parent.name
        if nearest:
            body = 'return ' + nearest[1] + ';'
            reference = 'combat_probe_legacy_nearest'
        else:
            body = 'return ' + match[1] + ';'
            reference = 'combat_probe_legacy_three' if 'grid_row - 1' in match[1] else 'combat_probe_legacy_front'
        probes += f'\nfunction combat_probe_actual_{name}() {{ {body} }}\n'
        calls.append(f'{{actual: combat_probe_actual_{name}, reference: {reference}, label: "{name}"}}')
    assert len(calls) == 24, 'Update probe coverage when migrating more query shapes'
    probes += '\nfunction combat_probe_calls() { return [' + ',\n'.join(calls) + ']; }\n'
    path = resource('scripts', 'combat_probe', copy.deepcopy(template))
    (path / 'combat_probe.gml').write_text(probes)

    def event(kind):
        return {'$GMEvent': 'v1', '%Name': '', 'collisionObjectId': None, 'eventNum': 0,
                'eventType': kind, 'isDnD': False, 'name': '', 'resourceType': 'GMEvent', 'resourceVersion': '2.0'}

    base = read_yy(ROOT / 'objects/obj_pool_holder/obj_pool_holder.yy')
    for name, parent in [('obj_enemy_parent', None), ('obj_card_parent', None), ('obj_ladder', None),
                         ('obj_normal_mouse', 'obj_enemy_parent'), ('obj_iron_pan_mouse', 'obj_enemy_parent'),
                         ('obj_xiao_long_bao', 'obj_card_parent'), ('obj_coffee_cup', 'obj_card_parent'),
                         ('obj_mod_battle_manager', None), ('obj_battle', None), ('obj_probe', None)]:
        obj = copy.deepcopy(base)
        obj.update(eventList=[], visible=False, spriteId=None, spriteMaskId=None, persistent=False)
        obj['parentObjectId'] = {'name': parent, 'path': f'objects/{parent}/{parent}.yy'} if parent else None
        path = resource('objects', name, obj)
        events = {}
        if name == 'obj_mod_battle_manager':
            events = {'Create_0': (0, (ROOT / f'objects/{name}/Create_0.gml').read_text()),
                      'Step_0': (3, (ROOT / f'objects/{name}/Step_0.gml').read_text()),
                      'CleanUp_0': (12, (ROOT / f'objects/{name}/CleanUp_0.gml').read_text())}
        elif name == 'obj_probe':
            events = {'Create_0': (0, 'try { combat_probe_run(); } catch (error) { show_debug_message(error); game_end(); }\n')}
        elif not parent:
            events = {'Create_0': (0, 'combat_targets_invalidate(object_index); grid_row = -1; grid_col = -1;\n'),
                      'Destroy_0': (1, 'combat_targets_invalidate(object_index);\n')}
        for filename, (kind, code) in events.items():
            obj['eventList'].append(event(kind))
            (path / f'{filename}.gml').write_text(code)
        write(path / f'{name}.yy', obj)
    room = read_yy(ROOT / 'rooms/room_init/room_init.yy')
    layer = next(layer for layer in room['layers'] if layer.get('resourceType') == 'GMRInstanceLayer')
    inst = layer['instances'][0]
    inst['objectId'] = {'name': 'obj_probe', 'path': 'objects/obj_probe/obj_probe.yy'}
    layer['instances'] = [inst]
    room.update(creationCodeFile='', layers=[layer],
                instanceCreationOrder=[{'name': inst['name'], 'path': 'rooms/probe_room/probe_room.yy'}],
                roomSettings={'Width': 320, 'Height': 180, 'inheritRoomSettings': False, 'persistent': False})
    resource('rooms', 'probe_room', room)
    project['RoomOrderNodes'] = [{'roomId': {'name': 'probe_room', 'path': 'rooms/probe_room/probe_room.yy'}}]
    project_file = source / 'FVMCombatTargetsCheck.yyp'
    write(project_file, project)
    runtime = build_macos.runtime_path(None)
    stage = work / 'stage'
    stage.mkdir(exist_ok=True)
    command = [*build_macos.igor_command(runtime), f'--project={project_file}', f'--rp={runtime}',
               f'--uf={build_macos.user_path(None)}', f'--cache={work / "cache"}', f'--temp={work / "temp"}',
               f'--of={stage / "game.zip"}', f'--tf={stage / "game.zip"}', '--runtime=VM', '--config=macOS',
               '-j=1', '--', 'Mac', 'Compile']
    with (work / 'build.log').open('w') as log:
        subprocess.run(list(map(str, command)), env={**os.environ, 'COMPlus_ZapDisable': '1'},
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    app = work / 'FVMCombatTargetsCheck.app'
    if app.exists():
        shutil.rmtree(app)
    subprocess.run(['ditto', '--noqtn', str(runtime / 'mac/YoYo Runner.app'), str(app)], check=True)
    resources = app / 'Contents/Resources'
    (resources / 'yoyorunner.config').unlink(missing_ok=True)
    with zipfile.ZipFile(stage / 'game.zip') as package:
        for entry in package.infolist():
            if entry.filename.startswith('assets/') and not entry.is_dir():
                relative = Path(entry.filename[len('assets/'):])
                if relative.is_absolute() or '..' in relative.parts:
                    raise RuntimeError('Unsafe compiler output')
                target = resources / relative
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(package.read(entry))
    info = app / 'Contents/Info.plist'
    metadata = plistlib.loads(info.read_bytes())
    metadata.update(CFBundleIdentifier='io.github.mgqs.fvm.combat-targets-check', CFBundleName='FVMCombatTargetsCheck')
    info.write_bytes(plistlib.dumps(metadata))
    build_macos.sign_app(app, '-', work)
    with (work / 'runtime.log').open('w') as log:
        result = subprocess.run([str(app / 'Contents/MacOS' / metadata['CFBundleExecutable'])],
                                cwd=resources, stdout=log, stderr=subprocess.STDOUT, timeout=45)
    output = (work / 'runtime.log').read_text(errors='replace')
    if result.returncode or 'COMBAT_TARGETS_FAIL' in output or 'COMBAT_TARGETS_PASS' not in output:
        raise RuntimeError('Combat probe failed; see ' + str(work / 'runtime.log'))
    for line in output.splitlines():
        if line.startswith(('COMBAT_BENCH ', 'COMBAT_TARGETS_PASS:')):
            print(line)


if __name__ == '__main__':
    check()
