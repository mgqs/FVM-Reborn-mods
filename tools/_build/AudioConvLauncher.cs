using System;
using System.IO;
using System.Reflection;
using System.Diagnostics;
using System.Windows.Forms;

// 音频转 OGG 图形版启动器
// 把 PowerShell 脚本作为嵌入资源编进 exe，运行时释放到临时目录再交给 powershell 执行。
// 这样分发时只需要一个 exe，不依赖旁边有没有 .ps1。
class AudioConvLauncher
{
    [STAThread]
    static void Main()
    {
        try
        {
            string dir = Path.Combine(Path.GetTempPath(), "FVM_AudioConv");
            Directory.CreateDirectory(dir);
            string script = Path.Combine(dir, "音频转OGG-GUI.ps1");

            Assembly asm = Assembly.GetExecutingAssembly();
            using (Stream res = asm.GetManifestResourceStream("conv.ps1"))
            {
                if (res == null)
                {
                    MessageBox.Show("内置脚本资源缺失，exe 可能已损坏。", "音频转 OGG",
                        MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
                using (FileStream fs = new FileStream(script, FileMode.Create, FileAccess.Write))
                {
                    res.CopyTo(fs);
                }
            }

            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = "powershell.exe";
            psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" + script + "\"";
            psi.UseShellExecute = false;
            psi.CreateNoWindow = true;
            psi.WorkingDirectory = dir;

            Process p = Process.Start(psi);
            if (p != null) p.WaitForExit();
        }
        catch (Exception ex)
        {
            MessageBox.Show("启动失败：\r\n" + ex.Message, "音频转 OGG",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
