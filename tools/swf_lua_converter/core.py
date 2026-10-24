"""Lossless SWF archive and deliberately fail-closed AS3 -> Mod API v1 conversion."""
from __future__ import annotations

import ctypes
import hashlib
import json
import math
import re
import shutil
import struct
import subprocess
import zlib
from pathlib import Path
from card_analysis import analyze_card
from card_adapters import adapt_card

CALLBACKS = ('on_create', 'on_step', 'on_timer', 'on_animation_event', 'on_animation_end', 'on_destroy')
OPS = {
    'shoot': {'sprite', 'damage', 'speed', 'speed_y', 'vertical_distance', 'row_offset', 'offset_x', 'offset_y', 'slow_ticks', 'damage_type'},
    'damage': {'target', 'amount', 'damage_type'}, 'heal': {'amount'}, 'produce': {'amount'},
    'animate': {'name'}, 'timer': {'seconds', 'name'}, 'remove': set(), 'log': {'message'},
}
CONTEXT_NUMBERS = set('id x y row col hp max_hp atk cycle range level shape skill dt'.split())


class Unsupported(ValueError):
    pass


def digest(data):
    return hashlib.sha256(data).hexdigest()


def abc_inventory(data):
    """Independent ABC structural parser; enumerate every method body, including initializers."""
    pos = 4
    if len(data) < 4: raise Unsupported('ABC 文件头截断')
    def read(n):
        nonlocal pos
        if pos + n > len(data): raise Unsupported('ABC 数据截断')
        value = data[pos:pos+n]; pos += n; return value
    def uint():
        value = 0
        for i in range(5):
            b = read(1)[0]; value |= (b & 127) << (7 * i)
            if b < 128: return value
        raise Unsupported('非法 ABC 变长整数')
    def traits():
        for _ in range(uint()):
            uint(); kind = read(1)[0]
            t = kind & 15
            if t in (0, 6):
                uint(); uint(); index = uint()
                if index: read(1)
            elif t in (1, 2, 3, 4, 5): uint(); uint()
            else: raise Unsupported(f'未知 ABC trait 类型 {t}')
            if kind & 64:
                for _ in range(uint()): uint()
    # Constant pool
    for _ in range(2):
        for _ in range(max(0, uint()-1)): uint()
    for _ in range(max(0, uint()-1)): read(8)
    for _ in range(max(0, uint()-1)): read(uint())
    for _ in range(max(0, uint()-1)): read(1); uint()
    for _ in range(max(0, uint()-1)):
        for _ in range(uint()): uint()
    for _ in range(max(0, uint()-1)):
        kind = read(1)[0]
        if kind in (7, 13, 9, 14): uint(); uint()
        elif kind in (15, 16, 27, 28): uint()
        elif kind in (17, 18): pass
        elif kind == 29:
            uint()
            for _ in range(uint()): uint()
        else: raise Unsupported(f'未知 ABC multiname 类型 {kind}')
    method_count = uint()
    for _ in range(method_count):
        count = uint(); uint()
        for _ in range(count): uint()
        uint(); flags = read(1)[0]
        if flags & 8:
            for _ in range(uint()): uint(); read(1)
        if flags & 128:
            for _ in range(count): uint()
    for _ in range(uint()):
        uint(); count = uint()
        for _ in range(count * 2): uint()
    class_count = uint()
    for _ in range(class_count):
        uint(); uint(); flags = read(1)[0]
        if flags & 8: uint()
        for _ in range(uint()): uint()
        uint(); traits()
    for _ in range(class_count): uint(); traits()
    script_count = uint()
    for _ in range(script_count): uint(); traits()
    bodies = []
    for _ in range(uint()):
        start = pos; method = uint()
        for _ in range(4): uint()
        length = uint(); code_start = pos; code = read(length)
        for _ in range(uint()):
            for _ in range(5): uint()
        traits()
        bodies.append({'method_index': method, 'record_offset': start, 'record_size': pos-start,
                       'code_offset': code_start, 'code_size': length, 'code_sha256': digest(code)})
    if pos != len(data): raise Unsupported('ABC 尾部存在未解析数据')
    if len({b['method_index'] for b in bodies}) != len(bodies): raise Unsupported('ABC 方法体索引重复')
    return {'method_count': method_count, 'class_count': class_count, 'script_count': script_count,
            'bodies': bodies, 'parsed_bytes': pos}


def write_json(path, payload):
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding='utf-8')


def write_report(out, report, records=()):
    write_json(out / 'report.json', report)
    lines = ['# SWF 提取与转换报告', '', f'状态：`{report["status"]}`',
             f'是否生成 Lua：{"是" if report.get("lua_emitted") else "否"}', '',
             '提取文件只覆盖这个 SWF。外部游戏引擎、外部 SWF 和动态依赖必须另行迁移。', '',
             f'类目录条目：{report.get("as3_catalog_entries", 0)}',
             f'导出源文件：{report.get("exported_sources", 0)}',
             f'源码函数数：{report.get("total_methods", 0)}',
             f'原始 ABC 方法体数：{report.get("abc_method_bodies", 0)}', '',
             '## 阻塞项', '']
    lines.extend('- ' + error for error in report['errors'])
    if not report['errors']: lines.append('完整性检查通过。适配输出不代表所有原版行为已转换，具体差异见 card_adaptation.json。')
    if report.get('dependency_report'):
        lines.extend(['', '## 单卡输出', '',
                      '入口：`' + report.get('selected_entry', '') + '`',
                      '转换后端：`' + report.get('adapter', '') + '`',
                      '完整脚本保留；依赖/排除分类见 `' + report['dependency_report'] + '`。',
                      '下方逐文件状态表示严格 AS3 子集支持情况，不是单卡适配结果。'])
    lines.extend(['', '## 每个源文件的转换情况', ''])
    for record in records:
        lines.append(f'- `{record["file"]}`：{record.get("reason", record["conversion"])}')
    lines.extend(['', '原 SWF、全部标签和 ABC 方法体保存在 original.swf / raw_tags；',
                  '单卡入口、依赖链与逐文件排除理由见 card_dependencies.json；适配规则、接口要求与差异见 card_adaptation.json。',
                  '反编译源码在 source，P-code 在 pcode；SHA-256 与清单见两个 inventory JSON。',
                  '反编译可能存在误差。DLL 加载验证只验证语法和初始化，不证明 Flash / Lua 行为等价。'])
    (out / '转换报告.md').write_text('\n'.join(lines), encoding='utf-8')


def archive_swf(source: Path, out: Path):
    """Keep every tag, including nested tags, not only guessed behavior tags."""
    raw = source.read_bytes()
    shutil.copy2(source, out / 'original.swf')
    if len(raw) < 9 or raw[:3] not in (b'FWS', b'CWS', b'ZWS'):
        raise Unsupported('不是有效的 FWS/CWS/ZWS 文件；原文件已经保留。')
    if raw[:3] == b'ZWS':
        raise Unsupported('暂不解析 LZMA/ZWS，请先用 JPEXS 解压为 FWS；不会生成 Lua。')
    if raw[:3] == b'CWS':
        decompressor = zlib.decompressobj()
        body = decompressor.decompress(raw[8:], 128 * 1024 * 1024 + 1)
        if len(body) > 128 * 1024 * 1024 or not decompressor.eof or decompressor.unused_data:
            raise Unsupported('压缩数据超限、截断或有未解析尾部。')
    else:
        body = raw[8:]
    if len(body) + 8 != struct.unpack_from('<I', raw, 4)[0]:
        raise Unsupported('SWF 声明长度与实际解压长度不同。')
    plain = b'FWS' + raw[3:8] + body
    (out / 'uncompressed.swf').write_bytes(plain)
    if not body: raise Unsupported('SWF 内容为空')
    rect_bytes = (5 + 4 * (body[0] >> 3) + 7) // 8
    if rect_bytes + 4 > len(body):
        raise Unsupported('SWF 文件头截断。')
    fps = struct.unpack_from('<H', body, rect_bytes)[0] / 256
    records, blockers = [], []
    tags_dir = out / 'raw_tags'
    tags_dir.mkdir()

    def scan(data, base, parent):
        pos, frame, ended = 0, 1, False
        while pos < len(data):
            start = pos
            if pos + 2 > len(data):
                raise Unsupported(f'标签头截断：{base + pos}')
            header = struct.unpack_from('<H', data, pos)[0]
            pos += 2
            code, size = header >> 6, header & 63
            if size == 63:
                if pos + 4 > len(data):
                    raise Unsupported('长标签长度截断')
                size = struct.unpack_from('<I', data, pos)[0]
                pos += 4
            if pos + size > len(data):
                raise Unsupported(f'标签 {code} 数据截断')
            payload = data[pos:pos + size]
            tag_id = len(records)
            filename = f'{tag_id:06d}_tag_{code}.bin'
            (tags_dir / filename).write_bytes(data[start:pos + size])
            rec = {'index': tag_id, 'code': code, 'offset': base + start,
                   'size': size, 'parent': parent, 'frame': frame, 'file': filename,
                   'sha256': digest(data[start:pos + size])}
            records.append(rec)
            if code in (12, 59, 7, 34, 26, 70, 94):
                rec['requires_timeline_review'] = True
            if code in (12, 59):
                blockers.append(f'AS1/2 动作标签 {tag_id}：不支持自动转换，原始数据已保留')
            if ((code in (26, 70) and payload and payload[0] & 128)
                    or code == 7 or (code == 34 and len(payload) >= 5 and struct.unpack_from('<H', payload, 3)[0])
                    or code == 94):
                blockers.append(f'按钮或剪辑动作标签 {tag_id}：需迁移时间轴脚本，不允许省略')
            if code in (57, 71, 87):
                blockers.append(f'外部导入或嵌入二进制标签 {tag_id}（{code}）：依赖需单独分析')
            if code in (72, 82):
                abc_start = 0
                if code == 82:
                    if len(payload) < 5:
                        raise Unsupported('DoABC 标签截断')
                    abc_start = payload.index(b'\0', 4) + 1
                abc = payload[abc_start:]
                (tags_dir / f'{tag_id:06d}.abc').write_bytes(abc)
                rec['abc_sha256'] = digest(abc)
                rec['abc_inventory'] = abc_inventory(abc)
                for method_body in rec['abc_inventory']['bodies']:
                    method_start = method_body['record_offset']
                    method_size = method_body['record_size']
                    (tags_dir / f'{tag_id:06d}_method_{method_body["method_index"]}.bin').write_bytes(abc[method_start:method_start+method_size])
            if code == 39:
                if size < 4:
                    raise Unsupported('DefineSprite 标签截断')
                rec['sprite_id'], rec['frame_count'] = struct.unpack_from('<HH', payload)
                scan(payload[4:], base + pos + 4, tag_id)
            if code == 1:
                frame += 1
            pos += size
            if code == 0:
                ended = True
                if pos != len(data):
                    blockers.append(f'End 标签后还有 {len(data) - pos} 字节：只存档，不认定完整转换')
                break
        if not ended:
            raise Unsupported('时间轴缺少 End 标签。')

    scan(body[rect_bytes + 4:], 8 + rect_bytes + 4, None)
    result = {'sha256': digest(raw), 'fps': fps, 'tags': records, 'blockers': blockers,
              'scope': '仅当前 SWF；外部 SWF、动态下载和原游戏运行状态不包含在文件中'}
    write_json(out / 'swf_inventory.json', result)
    return result


def ffdec_run(ffdec, args, logfile):
    result = subprocess.run([str(ffdec), *map(str, args)], capture_output=True,
                            timeout=600, creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
    stdout = result.stdout.decode('utf-8', errors='replace')
    stderr = result.stderr.decode('utf-8', errors='replace')
    logfile.write_text(stdout + '\n' + stderr, encoding='utf-8')
    if result.returncode:
        raise Unsupported(f'JPEXS 导出失败（{result.returncode}），查看 {logfile.name}')
    return stdout


def extract(source, output_parent, ffdec, progress=lambda message: None):
    source, output_parent, ffdec = map(Path, (source, output_parent, ffdec))
    if not source.is_file() or not ffdec.is_file():
        raise Unsupported('请选择有效 SWF 和 ffdec-cli.exe。')
    output_parent.mkdir(parents=True, exist_ok=True)
    name = re.sub(r'[^\w.-]', '_', source.stem) or 'swf'
    # Never reuse an old result: a previous logic.lua must not look like new success.
    out = output_parent / (name + '_' + digest(source.read_bytes())[:12])
    suffix = 1
    while out.exists():
        out = output_parent / (name + '_' + digest(source.read_bytes())[:12] + f'_{suffix}')
        suffix += 1
    out.mkdir()
    report = {'status': 'blocked', 'source': str(source), 'errors': [], 'lua_emitted': False}
    records = []
    try:
        progress('保存完整 SWF 和所有原始标签…')
        inventory = archive_swf(source, out)
        report['errors'].extend(inventory['blockers'])
        progress('核对 AS3 脚本目录…')
        dump = ffdec_run(ffdec, ['-dumpAS3', source], out / 'as3_inventory.log')
        ffdec_run(ffdec, ['-dumpAS2', source], out / 'as2_inventory.log')
        expected = []
        for line in dump.splitlines():
            match = re.fullmatch(r'([\w.$]+)\s+(\d+)', line.strip())
            if match:
                expected.append({'name': match[1], 'script_index': int(match[2])})
        progress('导出全部 ActionScript，禁止忽略导出错误…')
        ffdec_run(ffdec, ['-onerror', 'abort', '-export', 'script', out / 'source', source], out / 'source_export.log')
        progress('导出全部 P-code 字节码反汇编…')
        ffdec_run(ffdec, ['-onerror', 'abort', '-format', 'script:pcode', '-export', 'script', out / 'pcode', source], out / 'pcode_export.log')
        files = sorted((out / 'source').rglob('*.as'))
        records = []
        for file in files:
            text = file.read_text(encoding='utf-8-sig')
            package = re.search(r'\bpackage\s*([\w.]*)\s*\{', text)
            # A comment can contain "class name"; only declaration lines count.
            classes = re.findall(r'^\s*(?:(?:public|internal|private|protected|final|dynamic)\s+)*(?:class|interface)\s+(\w+)', text, re.M)
            qualified = [((package[1] + '.') if package and package[1] else '') + c for c in classes]
            record = {'file': str(file.relative_to(out)), 'sha256': digest(file.read_bytes()),
                      'classes': qualified, 'methods': re.findall(r'\bfunction\s+(?:get\s+|set\s+)?(\w+)\s*\(', text),
                      'imports': re.findall(r'\bimport\s+([\w.*]+)\s*;', text),
                      'base_classes': re.findall(r'\bextends\s+([\w.]+)', text),
                      'conversion': 'unconverted'}
            try:
                transpile(text)
                record['conversion'] = 'supported_subset'
            except Unsupported as error:
                record['reason'] = str(error)
            records.append(record)
        exported = {c for r in records for c in r['classes']}
        for record in records:
            record['external_imports'] = [c for c in record['imports'] if c not in exported]
        missing = [e['name'] for e in expected if e['name'] not in exported]
        if missing:
            report['errors'].append('类目录未覆盖：' + ', '.join(missing))
        if not expected:
            report['errors'].append('无法确认 AS3 类目录；不认定文本提取完整。')
        abc_classes = sum(t.get('abc_inventory', {}).get('class_count', 0) for t in inventory['tags'])
        if abc_classes != len(exported):
            report['errors'].append(f'原始 ABC 类数 {abc_classes} 与导出类数 {len(exported)} 不一致。')
        pcode_files = sorted((out / 'pcode').rglob('*.pcode'))
        if not pcode_files:
            report['errors'].append('未找到 P-code 导出文件。')
        pcode_inventory = []
        for file in pcode_files:
            pcode_inventory.append({'file': str(file.relative_to(out)), 'sha256': digest(file.read_bytes())})
        for record in records:
            relative = Path(record['file']).relative_to('source')
            expected_pcode = out / 'pcode' / relative.with_suffix('.pcode')
            if not expected_pcode.is_file():
                report['errors'].append('源码缺少对应 P-code：' + record['file'])
        write_json(out / 'pcode_inventory.json', pcode_inventory)
        for r in records:
            txt = (out / r['file']).read_text(encoding='utf-8-sig')
            if re.search(r'§§|decompilation error|decompilation timeout', txt, re.I):
                report['errors'].append('反编译异常：' + r['file'])
        write_json(out / 'scripts_inventory.json', {'expected': expected, 'missing': missing, 'files': records})
        report.update(as3_catalog_entries=len(expected), exported_sources=len(records),
                      total_methods=sum(len(r['methods']) for r in records),
                      unsupported_sources=sum(r['conversion'] != 'supported_subset' for r in records),
                      abc_method_bodies=sum(len(t.get('abc_inventory', {}).get('bodies', [])) for t in inventory['tags']),
                      pcode_files=len(pcode_files),
                      tag_count=len(inventory['tags']))
        report['status'] = 'extracted' if not report['errors'] else 'blocked'
        progress(f'已存档 {len(records)} 个脚本。未转换项目全部保留在报告中。')
    except Exception as error:
        report['errors'].append(str(error))
    write_report(out, report, records)
    return out, report


TOKEN = re.compile(r'\s+|//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"|\d+(?:\.\d+)?|[A-Za-z_$][\w$]*|==|!=|<=|>=|[{}().,:;=+*/<>-]')


class Parser:
    """Parse every token; no regex-based replacement or ignored function bodies."""
    def __init__(self, source):
        self.tokens, pos = [], 0
        for m in TOKEN.finditer(source):
            if m.start() != pos:
                raise Unsupported(f'不支持的字符或运算符：{source[pos:pos+24]!r}')
            pos = m.end()
            if not m[0].isspace() and not m[0].startswith(('//', '/*')):
                self.tokens.append((m[0], source[:m.start()].count('\n') + 1))
        if pos != len(source):
            raise Unsupported('无法解析源文件尾部。')
        self.i, self.state_types, self.locals = 0, {}, {}

    def peek(self):
        return self.tokens[self.i][0] if self.i < len(self.tokens) else '<EOF>'

    def take(self, wanted=None):
        got = self.peek()
        if wanted is not None and got != wanted:
            self.fail(f'需要 {wanted}，遇到 {got}')
        if got == '<EOF>':
            self.fail('源文件截断')
        self.i += 1
        return got

    def fail(self, message):
        line = self.tokens[min(self.i, len(self.tokens)-1)][1] if self.tokens else 1
        raise Unsupported(f'第 {line} 行：{message}')

    def identifier(self):
        result = self.take()
        if not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*', result) or result in {'end', 'local', 'then', 'repeat', 'until', 'and', 'or', 'not', 'nil', 'function', 'do', 'goto', 'in', 'for', 'while', 'if', 'else', 'elseif', 'break', 'return', 'true', 'false'}:
            self.fail('不支持的标识符 ' + result)
        return result

    def expression(self, precedence=0):
        token = self.peek()
        if token in ('-', '+'):
            self.take()
            rhs, typ = self.expression(30)
            if typ != 'Number': self.fail('一元运算要求 Number')
            value = ('(-' + rhs + ')') if token == '-' else rhs
        elif token == '(':
            self.take(); value, typ = self.expression(); self.take(')')
            value = '(' + value + ')'
        elif re.fullmatch(r'\d+(?:\.\d+)?', token):
            value, typ = self.take(), 'Number'
            if not math.isfinite(float(value)): self.fail('非有限数值字面量不支持')
            if '.' not in value: value += '.0'
        elif token.startswith('"'):
            raw = self.take()
            try: string = json.loads(raw)
            except ValueError: self.fail('仅支持 JSON 兼容字符串转义')
            # Lua escapes are not identical to JSON escapes: emit UTF-8 plus decimal control escapes.
            value = '"' + ''.join('\\\\' if c == '\\' else '\\"' if c == '"' else f'\\{ord(c):03d}' if ord(c) < 32 else c for c in string) + '"'
            typ = 'String'
        elif token in ('true', 'false'):
            value, typ = self.take(), 'Boolean'
        elif token == '{':
            self.take(); fields, names = [], {}
            if self.peek() != '}':
                while True:
                    key = self.identifier()
                    if key in names: self.fail('对象键重复')
                    self.take(':'); expr, field_type = self.expression(); names[key] = field_type
                    fields.append('["' + key + '"] = ' + expr)
                    if self.peek() != ',': break
                    self.take(',')
            self.take('}'); value, typ = '{' + ', '.join(fields) + '}', ('Object', names)
        else:
            name = self.identifier()
            if name in ('ctx', 'state'):
                self.take('.'); field = self.identifier(); value = name + '.' + field
                typ = 'Number' if name == 'ctx' and field in CONTEXT_NUMBERS else self.state_types.get(field) if name == 'state' else None
                if typ is None: self.fail('未支持或未初始化的属性 ' + value)
            elif name == 'Math':
                self.take('.'); fn = self.identifier()
                if fn not in ('min', 'max', 'floor', 'ceil', 'abs'): self.fail('不支持 Math.' + fn)
                self.take('('); args = []
                while self.peek() != ')':
                    expr, argtype = self.expression()
                    if argtype != 'Number': self.fail('Math 参数必须为 Number')
                    args.append(expr)
                    if self.peek() != ',': break
                    self.take(',')
                self.take(')')
                if (fn in ('min', 'max') and len(args) < 1) or (fn not in ('min', 'max') and len(args) != 1): self.fail('Math 参数数量不兼容')
                value, typ = 'math.' + fn + '(' + ', '.join(args) + ')', 'Number'
            elif name in self.locals:
                value, typ = name, self.locals[name]
            else:
                self.fail('未映射的变量、方法或原游戏依赖 ' + name)
        levels = {'==': 5, '!=': 5, '<': 5, '>': 5, '<=': 5, '>=': 5, '+': 10, '-': 10, '*': 20, '/': 20}
        while self.peek() in levels and levels[self.peek()] > precedence:
            op = self.take(); rhs, rt = self.expression(levels[op])
            if typ != 'Number' or rt != 'Number': self.fail('仅支持 Number 运算及比较，拒绝隐式类型转换')
            value = '(' + value + (' ~= ' if op == '!=' else ' ' + op + ' ') + rhs + ')'
            typ = 'Boolean' if levels[op] == 5 else 'Number'
        return value, typ

    def block(self, depth=1):
        self.take('{'); lines = []
        while self.peek() != '}':
            prefix = '    ' * depth
            token = self.peek()
            if token == 'var':
                self.take(); name = self.identifier(); self.take(':'); typ = self.take()
                if typ not in ('Number', 'Boolean', 'String'): self.fail('仅支持 Number/Boolean/String 局部变量，int/uint 强制转换不可忽略')
                if name in self.locals or name in ('ctx', 'state', 'api', 'math'): self.fail('局部变量重复或遮蔽运行时接口')
                self.take('='); value, inferred = self.expression(); self.take(';')
                if inferred != typ: self.fail('局部变量类型不一致')
                self.locals[name] = typ; lines.append(prefix + 'local ' + name + ' = ' + value)
            elif token == 'if':
                self.take(); self.take('('); cond, typ = self.expression(); self.take(')')
                if typ != 'Boolean': self.fail('if 必须为 Boolean，不能依赖 AS 的真值转换')
                saved_locals, saved_state = self.locals.copy(), self.state_types.copy()
                lines.append(prefix + 'if ' + cond + ' then'); lines.extend(self.block(depth + 1))
                self.locals, self.state_types = saved_locals.copy(), saved_state.copy()
                if self.peek() == 'else':
                    self.take(); lines.append(prefix + 'else'); lines.extend(self.block(depth + 1))
                self.locals, self.state_types = saved_locals, saved_state
                lines.append(prefix + 'end')
            elif token == 'return':
                self.take(); self.take(';'); lines.append(prefix + 'do return end')
            elif token == 'api':
                self.take(); self.take('.'); operation = self.identifier()
                if operation not in OPS: self.fail('游戏 API 不支持 ' + operation)
                self.take('('); value, typ = self.expression(); self.take(')'); self.take(';')
                if not isinstance(typ, tuple) or not set(typ[1]) <= OPS[operation]: self.fail('API 参数必须为支持的对象字段')
                for key, field_type in typ[1].items():
                    expected_type = 'String' if key in ('sprite', 'damage_type', 'name', 'message') else 'Number'
                    if field_type != expected_type: self.fail('API 参数类型错误：' + key)
                lines.append(prefix + 'api.' + operation + '(' + value + ')')
            else:
                target = self.identifier()
                if target == 'state':
                    self.take('.'); field = self.identifier(); target += '.' + field
                elif target not in self.locals: self.fail('未映射的语句或变量 ' + target)
                self.take('='); value, typ = self.expression(); self.take(';')
                if isinstance(typ, tuple): self.fail('不支持跨回调对象状态')
                if target.startswith('state.'):
                    field = target[6:]
                    if field in self.state_types and self.state_types[field] != typ: self.fail('状态类型改变')
                    self.state_types[field] = typ
                elif self.locals[target] != typ: self.fail('赋值类型不一致')
                lines.append(prefix + target + ' = ' + value)
        self.take('}')
        return lines

    def parse(self):
        self.take('package')
        if self.peek() != '{':
            self.identifier()
            while self.peek() == '.': self.take(); self.identifier()
        self.take('{'); self.take('public'); self.take('class'); class_name = self.identifier()
        if self.peek() == 'extends':
            self.take(); base = self.identifier()
            if base != 'Object': self.fail('父类需要完整迁移：' + base)
        self.take('{'); callbacks = {}
        constructor = False
        while self.peek() != '}':
            self.take('public'); self.take('function'); name = self.identifier(); self.take('(')
            if name == class_name:
                if constructor: self.fail('重复构造函数')
                constructor = True; self.take(')'); self.take('{'); self.take('}')
                continue
            if name not in CALLBACKS or name in callbacks: self.fail('未映射的方法或重复回调 ' + name)
            self.take('ctx'); self.take(':'); self.take('Object'); self.take(',')
            self.take('state'); self.take(':'); self.take('Object'); self.take(')'); self.take(':'); self.take('void')
            self.locals = {}
            callbacks[name] = self.block()
        self.take('}'); self.take('}')
        if self.peek() != '<EOF>': self.fail('未解析的类外脚本')
        if not callbacks: self.fail('没有 Mod API v1 回调')
        # AS3 member definition order is irrelevant; require initialization first rather than guess.
        lua = '-- Strict AS3 subset conversion. No source statements were ignored.\nreturn {\n'
        for name, body in callbacks.items():
            lua += '  ' + name + ' = function(ctx, state)\n' + '\n'.join(body) + '\n  end,\n'
        return lua + '}\n'


def transpile(source):
    return Parser(source).parse()


def validate_lua(source, dll_path):
    library = ctypes.CDLL(str(Path(dll_path).resolve()))
    create = library.ModLuaCreate
    create.argtypes, create.restype = [ctypes.c_char_p], ctypes.c_char_p
    destroy = library.ModLuaDestroy
    destroy.argtypes, destroy.restype = [ctypes.c_double], ctypes.c_double
    result = json.loads(create(source.encode('utf-8')))
    if not result.get('ok'):
        raise Unsupported('实际游戏 Lua DLL 拒绝脚本：' + str(result.get('error')))
    destroy(result['handle'])
    return {'syntax_and_initialization': 'passed', 'behavior_equivalence': 'not_proven',
            'note': '加载通过不等于原游戏行为等价；运行轨迹和战场行为仍需测试'}


def convert_session(out, dll_path, entry=None):
    """Select a card, account for every source, then use a supported backend."""
    out = Path(out)
    report = json.loads((out / 'report.json').read_text(encoding='utf-8'))
    inventory = json.loads((out / 'scripts_inventory.json').read_text(encoding='utf-8'))
    # A conversion rejection must not turn a successful extraction into a corrupt-file error.
    # Old capability rejections can be retried after upgrading the converter;
    # extraction/integrity errors remain fatal.
    if report['status'] == 'conversion_blocked':
        report['errors'] = [e for e in report['errors'] if not e.startswith(('严格模式阻止输出：', '提取完整性检查通过，但转换器尚未实现', '卡片转换阻塞：'))]
    if report['status'] not in ('extracted', 'conversion_blocked', 'lua_validated_subset', 'lua_adapted_unverified') or report['errors']:
        raise Unsupported('提取完整性检查未通过，不能转换；查看 report.json。')
    items = inventory['files']
    # Remove stale successes before any checks, never leave an old Lua on failure.
    (out / 'logic.lua').unlink(missing_ok=True)
    (out / 'card_adaptation.json').unlink(missing_ok=True)
    sources = {}
    try:
        swf_info = json.loads((out / 'swf_inventory.json').read_text(encoding='utf-8'))
        if digest((out / 'original.swf').read_bytes()) != swf_info['sha256'] or swf_info['blockers']:
            raise Unsupported('原 SWF 完整性校验未通过。')
        for item in items:
            text_path = out / item['file']
            if digest(text_path.read_bytes()) != item['sha256']:
                raise Unsupported('提取源文件已修改：' + item['file'])
            sources[item['file']] = text_path.read_text(encoding='utf-8-sig')
        # Class metadata in the inventory must agree with the immutable source.
        for item in items:
            parsed_names = re.findall(r'^\s*(?:(?:public|internal|private|protected|final|dynamic)\s+)*(?:class|interface)\s+(\w+)', sources[item['file']], re.M)
            if sorted(c.rsplit('.', 1)[-1] for c in item['classes']) != sorted(parsed_names):
                raise Unsupported('类清单与源文件不一致：' + item['file'])
        analysis = analyze_card(items, sources, entry)
        write_json(out / 'card_dependencies.json', analysis)
        if not analysis['entry']:
            raise Unsupported('无法唯一识别卡片入口，请选择入口类；候选见 card_dependencies.json。')
        adapted = adapt_card(out, items, analysis)
        details = None
        if adapted:
            lua, details = adapted
        else:
            selected = [r for r in items if analysis['entry'] in r['classes']]
            if len(analysis['reachable_classes']) != 1 or analysis['external_dependencies'] or len(selected) != 1:
                raise Unsupported('所选卡片的父类/方法依赖尚无适配器；见 card_dependencies.json。不会套用其他卡片逻辑。')
            lua = transpile(sources[selected[0]['file']])
        if len(lua.encode('utf-8')) > 262144:
            raise Unsupported('Lua 超过游戏 256 KB 上限')
        check = validate_lua(lua, dll_path)
    except (Unsupported, ValueError, OSError, KeyError) as error:
        report.update(status='conversion_blocked', lua_emitted=False)
        for stale_key in ('lua_sha256', 'lua_validation', 'selected_entry', 'adapter', 'dependency_report',
                          'converted_sources', 'adapted_sources', 'analyzed_dependencies', 'adapted_behavior_mapping'):
            report.pop(stale_key, None)
        report['errors'].append('卡片转换阻塞：' + str(error))
        write_report(out, report, items)
        raise Unsupported(report['errors'][-1]) from error
    (out / 'logic.lua').write_text(lua, encoding='utf-8')
    if details:
        write_json(out / 'card_adaptation.json', details)
    report.update(status='lua_adapted_unverified' if details else 'lua_validated_subset', lua_emitted=True,
                  errors=[], lua_validation=check, selected_entry=analysis['entry'],
                  adapter=details['adapter'] if details else 'strict_as3_subset',
                  dependency_report='card_dependencies.json',
                  converted_sources=[] if details else [selected[0]['file']],
                  analyzed_dependencies=analysis['reachable_classes'],
                  adapted_behavior_mapping=details['behavior_mapping'] if details else [],
                  lua_sha256=digest(lua.encode('utf-8')))
    report.pop('adapted_sources', None)
    write_report(out, report, items)
    return out / 'logic.lua'
