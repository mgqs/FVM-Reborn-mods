using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

internal static class Launcher
{
    [STAThread]
    private static void Main()
    {
        string page = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "FVM Reborn", "Level Workshop", "index.html");
        try
        {
            Directory.CreateDirectory(Path.GetDirectoryName(page));
            using (Stream resource = Assembly.GetExecutingAssembly().GetManifestResourceStream("index.html"))
            {
                if (resource == null)
                    throw new FileNotFoundException("程序内未包含编辑器页面资源。");
                using (FileStream target = File.Create(page))
                    resource.CopyTo(target);
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show("准备关卡工坊页面失败：\r\n" + ex.Message, "关卡工坊", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        string[] edgePaths = {
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86), "Microsoft", "Edge", "Application", "msedge.exe"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles), "Microsoft", "Edge", "Application", "msedge.exe")
        };
        string edge = Array.Find(edgePaths, File.Exists);
        if (edge == null)
        {
            MessageBox.Show("未找到 Microsoft Edge。安装 Edge 后即可运行关卡工坊。", "关卡工坊", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return;
        }

        try
        {
            string url = new Uri(page).AbsoluteUri;
            Process.Start(new ProcessStartInfo {
                FileName = edge,
                Arguments = "--app=\"" + url + "\" --no-first-run",
                UseShellExecute = false
            });
        }
        catch (Exception ex)
        {
            MessageBox.Show("启动关卡工坊失败：\r\n" + ex.Message, "关卡工坊", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
