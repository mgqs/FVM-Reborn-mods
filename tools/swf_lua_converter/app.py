"""Chinese desktop UI and command-line entry point. No network or AI service required."""
import argparse
import os
from pathlib import Path
import queue
import threading
import tkinter as tk
from tkinter import filedialog, messagebox, ttk

from core import extract, convert_session, Unsupported

ROOT = Path(__file__).resolve().parents[2]


def gui():
    window = tk.Tk()
    window.title('SWF 卡片行为提取与 Lua 转换 · 严格模式')
    window.geometry('850x600')
    swf = tk.StringVar()
    ffdec = tk.StringVar(value=str(ROOT / '.codex-tmp/ffdec/ffdec-cli.exe'))
    dll = tk.StringVar(value=str(ROOT / 'datafiles/native/FvmNativeSupport.dll'))
    output = tk.StringVar(value=str(ROOT / 'output/swf_lua_converter'))
    entry = tk.StringVar()
    session = None
    messages = queue.Queue()
    busy = False
    frame = ttk.Frame(window, padding=18)
    frame.pack(fill='both', expand=True)
    ttk.Label(frame, text='全脚本提取 · 保留原始字节码 · 未支持的行为阻止转换', font=('Microsoft YaHei', 14)).pack(anchor='w')
    ttk.Label(frame, text='自动识别卡片入口、分析依赖，输出单个适配 Lua。当前支持简单回调类及已核对版本的终极三线枪；其他行为明确报错。', wraplength=780).pack(anchor='w', pady=(5, 15))

    def field(label, variable, directory=False, pattern='*.*'):
        row = ttk.Frame(frame); row.pack(fill='x', pady=4)
        ttk.Label(row, text=label, width=13).pack(side='left')
        ttk.Entry(row, textvariable=variable).pack(side='left', fill='x', expand=True)
        def choose():
            path = filedialog.askdirectory() if directory else filedialog.askopenfilename(filetypes=[('文件', pattern)])
            if path: variable.set(path)
        ttk.Button(row, text='选择', command=choose).pack(side='left', padx=(8, 0))

    field('SWF 文件', swf, pattern='*.swf')
    field('JPEXS 程序', ffdec, pattern='*.exe')
    field('游戏 Lua DLL', dll, pattern='*.dll')
    field('结果存放目录', output, directory=True)
    entry_row = ttk.Frame(frame); entry_row.pack(fill='x', pady=4)
    ttk.Label(entry_row, text='卡片入口类', width=13).pack(side='left')
    ttk.Entry(entry_row, textvariable=entry).pack(side='left', fill='x', expand=True)
    ttk.Label(entry_row, text='可留空自动识别').pack(side='left', padx=8)
    row = ttk.Frame(frame); row.pack(fill='x', pady=12)
    log = tk.Text(frame, wrap='word', height=15, font=('Microsoft YaHei', 10))
    scroll = ttk.Scrollbar(frame, command=log.yview)
    scroll.pack(side='right', fill='y'); log.pack(fill='both', expand=True)
    log.configure(yscrollcommand=scroll.set, state='disabled')
    status = tk.StringVar(value='请选择 SWF，点击“提取全部脚本”。不会修改游戏或原 SWF。')
    ttk.Label(frame, textvariable=status, wraplength=780).pack(anchor='w', pady=10)

    def run_job(conversion=False):
        nonlocal busy
        if busy: return
        if conversion and session is None:
            messagebox.showinfo('先提取', '请先提取并核对完整脚本。'); return
        args = (swf.get(), output.get(), ffdec.get())
        current_session, current_dll = session, dll.get()
        current_entry = entry.get().strip() or None
        busy = True
        for button in buttons: button.configure(state='disabled')
        def worker():
            try:
                if conversion:
                    path = convert_session(current_session, current_dll, current_entry)
                    messages.put(('text', '生成单卡 Lua：' + str(path) + '\nDLL 加载通过。请查看 card_dependencies.json 和 card_adaptation.json；新接口需新版游戏源码，战场效果尚未验证。'))
                else:
                    folder, report = extract(*args, progress=lambda s: messages.put(('text', s)))
                    messages.put(('session', folder))
                    messages.put(('text', f'结果目录：{folder}\n脚本数量：{report.get("exported_sources", 0)}；状态：{report["status"]}'))
                    for error in report['errors']: messages.put(('text', '阻塞：' + error))
                    if report.get('unsupported_sources'): messages.put(('text', f'{report["unsupported_sources"]} 个脚本不属于简单 AS3 子集。这不代表单卡适配一定失败；请点击转换，查看入口和依赖分析结果。'))
            except Exception as error: messages.put(('text', '未生成可用 Lua：' + str(error)))
            finally: messages.put(('done', None))
        threading.Thread(target=worker, daemon=True).start()

    buttons = [ttk.Button(row, text='1. 提取全部脚本', command=run_job),
               ttk.Button(row, text='2. 严格转换为 Lua', command=lambda: run_job(True))]
    for button in buttons: button.pack(side='left', padx=(0, 12))
    def open_result():
        path = session or Path(output.get())
        if Path(path).is_dir(): os.startfile(path)
    ttk.Button(row, text='打开结果目录', command=open_result).pack(side='left')

    def poll():
        nonlocal busy, session
        while not messages.empty():
            kind, item = messages.get()
            if kind == 'session': session = item
            elif kind == 'done':
                busy = False
                for button in buttons: button.configure(state='normal')
                status.set('任务结束。原始数据、脚本清单和转换阻塞项均在结果目录。')
            else:
                log.configure(state='normal'); log.insert('end', item + '\n'); log.see('end'); log.configure(state='disabled')
                status.set(item.split('\n')[0])
        window.after(100, poll)
    def close():
        if busy:
            messagebox.showinfo('正在处理', '为避免留下不完整导出，请等待任务结束后关闭窗口。'); return
        window.destroy()
    window.protocol('WM_DELETE_WINDOW', close)
    poll(); window.mainloop()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='SWF strict extractor/converter')
    parser.add_argument('--swf'); parser.add_argument('--out', default=str(ROOT / 'output/swf_lua_converter'))
    parser.add_argument('--ffdec', default=str(ROOT / '.codex-tmp/ffdec/ffdec-cli.exe'))
    parser.add_argument('--convert-session'); parser.add_argument('--dll', default=str(ROOT / 'datafiles/native/FvmNativeSupport.dll'))
    parser.add_argument('--entry', help='Optional fully qualified card entry class')
    args = parser.parse_args()
    if args.convert_session:
        try: print(convert_session(args.convert_session, args.dll, args.entry))
        except Unsupported as error: parser.exit(2, str(error) + '\n')
    elif args.swf:
        folder, report = extract(args.swf, args.out, args.ffdec, print)
        print(folder); print(report)
        if report['status'] != 'extracted': parser.exit(2)
    else: gui()
