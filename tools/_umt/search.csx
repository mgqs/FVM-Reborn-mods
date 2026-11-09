/**/
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

var sb = new StringBuilder();
sb.AppendLine("=== SUMMARY ===");
sb.AppendLine("Code=" + Data.Code.Count + " Sprites=" + Data.Sprites.Count + " Objects=" + Data.GameObjects.Count + " Sounds=" + Data.Sounds.Count + " Strings=" + Data.Strings.Count + " Fonts=" + Data.Fonts.Count);

string[] keys = { "海神", "诸神", "死神", "标枪", "神盾", "之盾", "之镰", "poseidon", "trident", "aegis", "scythe", "thanatos", "hades", "shiva", "weapon_gem", "gods_" };

sb.AppendLine("");
sb.AppendLine("=== STRINGS (含关键词) ===");
int n = 0;
foreach (var s in Data.Strings) {
    var c = s.Content;
    if (string.IsNullOrEmpty(c)) continue;
    for (int i = 0; i < keys.Length; i++) {
        if (c.IndexOf(keys[i], StringComparison.OrdinalIgnoreCase) >= 0) {
            sb.AppendLine("[" + keys[i] + "] " + c);
            n++;
            break;
        }
    }
    if (n > 4000) { sb.AppendLine("...(截断)"); break; }
}

sb.AppendLine("");
sb.AppendLine("=== SPRITES (含关键词) ===");
foreach (var s in Data.Sprites) {
    var nm = s.Name == null ? "" : s.Name.Content;
    if (string.IsNullOrEmpty(nm)) continue;
    for (int i = 0; i < keys.Length; i++) {
        if (nm.IndexOf(keys[i], StringComparison.OrdinalIgnoreCase) >= 0) { sb.AppendLine(nm); break; }
    }
}

sb.AppendLine("");
sb.AppendLine("=== OBJECTS (含关键词) ===");
foreach (var o in Data.GameObjects) {
    var nm = o.Name == null ? "" : o.Name.Content;
    if (string.IsNullOrEmpty(nm)) continue;
    for (int i = 0; i < keys.Length; i++) {
        if (nm.IndexOf(keys[i], StringComparison.OrdinalIgnoreCase) >= 0) { sb.AppendLine(nm); break; }
    }
}

sb.AppendLine("");
sb.AppendLine("=== CODE (含关键词) ===");
foreach (var c0 in Data.Code) {
    var nm = c0.Name == null ? "" : c0.Name.Content;
    if (string.IsNullOrEmpty(nm)) continue;
    for (int i = 0; i < keys.Length; i++) {
        if (nm.IndexOf(keys[i], StringComparison.OrdinalIgnoreCase) >= 0) { sb.AppendLine(nm); break; }
    }
}

File.WriteAllText(@"D:\gameProject\FVM-Reborn-mod\tools\_umt\search.txt", sb.ToString(), new UTF8Encoding(false));
