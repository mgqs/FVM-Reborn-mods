using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

internal static class Launcher
{
    private static string _selfDir;

    [STAThread]
    private static void Main()
    {
        _selfDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

        // 优先使用 exe 同目录（或工程里 tools\level_editor）的 index.html：
        // 这样卡片/敌人/龙柱图标才能按相对路径取到 sprites\ 下的 png。
        string page = FindOnDiskPage();
        if (page == null) page = ExtractEmbedded();
        if (page == null) return;

        string browser = FindBrowser(new[] {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Microsoft", "Edge", "Application", "msedge.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Microsoft", "Edge", "Application", "msedge.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Google", "Chrome", "Application", "chrome.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Google", "Chrome", "Application", "chrome.exe")
        });
        if (browser == null)
        {
            MessageBox.Show("未找到 Edge / Chrome 浏览器，无法启动关卡工坊。", "关卡工坊", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        try
        {
            string url = new Uri(page).AbsoluteUri;
            Process.Start(new ProcessStartInfo {
                FileName = browser,
                Arguments = "--app=\"" + url + "\" --no-first-run --allow-file-access-from-files",
                UseShellExecute = false
            });
        }
        catch (Exception ex)
        {
            MessageBox.Show("启动关卡工坊失败：\r\n" + ex.Message, "关卡工坊", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private static string FindBrowser(string[] paths)
    {
        foreach (string p in paths)
            if (File.Exists(p)) return p;
        return null;
    }

    // 依次查找：exe 同目录 → 逐级向上找 tools\level_editor\index.html → 工程根
    private static string FindOnDiskPage()
    {
        string direct = Path.Combine(_selfDir, "index.html");
        if (File.Exists(direct) && File.Exists(Path.Combine(_selfDir, "data.js"))) return direct;

        DirectoryInfo dir = new DirectoryInfo(_selfDir);
        for (int i = 0; i < 5 && dir != null; i++)
        {
            string candidate = Path.Combine(dir.FullName, @"tools\level_editor\index.html");
            if (File.Exists(candidate) && File.Exists(Path.Combine(dir.FullName, @"tools\level_editor\data.js")))
                return candidate;
            dir = dir.Parent;
        }
        return null;
    }

    // 兜底：把内嵌的 index.html / data.js 释放到本地，供没有工程目录的情况使用
    private static string ExtractEmbedded()
    {
        string dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                                  "FVM Reborn", "Level Workshop");
        try
        {
            Directory.CreateDirectory(dir);
            Assembly asm = Assembly.GetExecutingAssembly();
            Extract(asm, "index.html", Path.Combine(dir, "index.html"));
            Extract(asm, "data.js", Path.Combine(dir, "data.js"));
        }
        catch (Exception ex)
        {
            MessageBox.Show("准备关卡工坊页面失败：\r\n" + ex.Message, "关卡工坊", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return null;
        }
        return Path.Combine(dir, "index.html");
    }

    private static void Extract(Assembly asm, string name, string target)
    {
        using (Stream resource = asm.GetManifestResourceStream(name))
        {
            if (resource == null) return;
            using (FileStream fs = File.Create(target))
                resource.CopyTo(fs);
        }
    }
}
