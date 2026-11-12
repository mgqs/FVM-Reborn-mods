import io

p = r"D:\gameProject\FVM-Reborn-mod\objects\obj_honglonglong\Step_0.gml"
raw = open(p, "rb").read()
print("CRLF" if b"\r\n" in raw else "LF only", len(raw), "bytes")
t = raw.decode("utf-8")
lines = t.split("\n")
for i in range(275, 318):
    print(i + 1, repr(lines[i]))
