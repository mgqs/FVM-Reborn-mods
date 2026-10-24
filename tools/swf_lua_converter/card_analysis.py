"""Conservative class dependency analysis, independent of card-specific adapters.

Imports are deliberately over-approximated. An unreachable class can be excluded;
a reachable unknown class is never declared converted just because it was saved.
"""
import re


def without_comments_and_strings(source):
    return re.sub(r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', ' ', source)


def analyze_card(records, sources, entry=None):
    owners = {name: rec for rec in records for name in rec['classes']}
    edges, unresolved, method_inventory, special = {}, {}, {}, {}
    for name, rec in owners.items():
        text = without_comments_and_strings(sources[rec['file']])
        package = name.rpartition('.')[0]
        imports = rec.get('imports', [])
        references = set(re.findall(r'\b[A-Za-z_$][\w$]*\b', text))
        deps, unknown = set(), set()
        for imported in imports:
            if imported.endswith('.*'):
                prefix = imported[:-1]
                deps.update(c for c in owners if c.startswith(prefix) and c.rsplit('.', 1)[-1] in references)
            elif imported in owners:
                deps.add(imported)  # include even unused imports conservatively
            elif not imported.startswith('flash.'):
                unknown.add(imported)
        deps.update(c for c in owners if c.rpartition('.')[0] == package and c.rsplit('.', 1)[-1] in references)
        for base in rec.get('base_classes', []):
            matches = [c for c in owners if c == base or c == package + '.' + base or c in imports and c.endswith('.' + base)]
            if not matches and base not in ('Object', 'Sprite', 'MovieClip'):
                unknown.add(base)
            deps.update(matches)
        deps.discard(name)
        edges[name] = sorted(deps)
        unresolved[name] = sorted(unknown)
        original = sources[rec['file']]
        method_inventory[name] = re.findall(r'\bfunction\s+(?:get\s+|set\s+)?(\w+)\s*\(', text)
        special[name] = {
            'static_initialization': bool(re.search(r'\bstatic\s+(?:var|const)\b', text)),
            'frame_scripts': re.findall(r'\bfunction\s+(frame\d+)\s*\(', text),
            'calls': sorted(set(re.findall(r'\b([A-Za-z_$][\w$]*)\s*\(', text)) - {'if', 'while', 'for', 'switch', 'catch', 'function'}),
            'dynamic_loading_or_reflection': sorted(set(re.findall(r'\b(getDefinitionByName|loadBytes|load|Loader|ExternalInterface|eval)\b', text))),
            'embedded_symbol': re.findall(r'\bEmbed\s*\([^)]*\)', original)
        }
    candidates = []
    for name, rec in owners.items():
        text = sources[rec['file']]
        if re.search(r'\bimplements\s+IResource\b', text) and re.search(r'function\s+a_3932\s*\(', text):
            candidates.append(name)
    if entry is None:
        if len(candidates) == 1:
            entry = candidates[0]
        elif len(records) == 1 and len(owners) == 1:
            entry = next(iter(owners))
    if entry is not None and entry not in owners:
        raise ValueError('入口类不在 SWF 中：' + entry)
    reached, queue, paths = set(), [entry] if entry else [], {entry: [entry]} if entry else {}
    while queue:
        current = queue.pop()
        if current in reached:
            continue
        reached.add(current)
        for dep in edges[current]:
            if dep not in paths:
                paths[dep] = paths[current] + [dep]
            queue.append(dep)
    files = []
    for rec in records:
        active = [c for c in rec['classes'] if c in reached]
        files.append({'file': rec['file'], 'classes': rec['classes'],
                      'classification': 'behavior_dependency' if active else 'excluded' if entry else 'unresolved_entry',
                      'reason': '入口及保守静态依赖链' if active else
                      '未从所选入口的保守类依赖图到达；仅对无动态类加载且已验证的适配器有效' if entry else '尚未确定卡片入口，不能排除',
                      'dependency_paths': [paths[c] for c in active]})
    return {'entry': entry, 'entry_candidates': sorted(candidates), 'edges': edges,
            'methods': {c: method_inventory[c] for c in sorted(reached)},
            'special_dependencies': {c: special[c] for c in sorted(reached)},
            'reachable_classes': sorted(reached), 'external_dependencies': {c: unresolved[c] for c in sorted(reached) if unresolved[c]},
            'files': files, 'analysis_limits': ['保守类级依赖，不是通用 AS3 方法级数据流证明',
                '动态反射、外部 SWF、帧脚本需由转换器或经过核对的适配器进一步处理；分析报告本身不授权输出 Lua']}
