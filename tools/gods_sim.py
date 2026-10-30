import random

def random_reward():
    r = random.randrange(1000)
    if r < 244: return ("金币", 1000, 0)
    if r < 334: return ("金币", 5000, 0)
    if r < 374: return ("金币", 10000, 0)
    if r < 377: return ("神谕之石", 5, 5)
    if r < 379: return ("神谕之石", 10, 10)
    if r < 380: return ("神谕之石", 25, 25)
    if r < 510: return ("天然香料", 25, 0)
    if r < 550: return ("天然香料", 50, 0)
    if r < 560: return ("天然香料", 200, 0)
    if r < 650: return ("秘制香料", 25, 0)
    if r < 670: return ("秘制香料", 50, 0)
    if r < 680: return ("秘制香料", 200, 0)
    if r < 780: return ("初级强化水晶", 25, 0)
    if r < 820: return ("初级强化水晶", 50, 0)
    if r < 890: return ("中级强化水晶", 25, 0)
    if r < 920: return ("中级强化水晶", 50, 0)
    if r < 950: return ("4级四叶草", 5, 0)
    return ("高级强化水晶", 50, 0)

def guarantee_reward(pity):
    if pity % 2 == 0:
        r = random.randrange(100)
        if r < 60: return ("4级四叶草", 25, 0)
        if r < 80: return ("高级强化水晶", 25, 0)
        r2 = random.randrange(100)
        if r2 < 60: return ("神谕之石", 5, 5)
        if r2 < 80: return ("神谕之石", 10, 10)
        return ("神谕之石", 25, 25)
    r = random.randrange(100)
    if r < 60: return ("神谕之石", 5, 5)
    if r < 80: return ("神谕之石", 10, 10)
    return ("神谕之石", 25, 25)

wish = 0
pity = 0
N = 5_000_000
stones = 0
gold_gained = 0
pity_hits = 0
pity_stone_hits = 0
stone_hits = 0
clover = 0
adv = 0
from collections import Counter
cnt = Counter()
for i in range(N):
    is_pity = wish >= 50
    rew = guarantee_reward(pity) if is_pity else random_reward()
    name, num, st = rew
    cnt[name] += 1
    if is_pity:
        pity_hits += 1
        if st > 0: pity_stone_hits += 1
    if name == "金币":
        gold_gained += num
        wish += 1
        continue
    if st > 0:
        stones += num
        stone_hits += 1
        wish = 0
        if is_pity: pity += 1
        continue
    if name in ("4级四叶草", "高级强化水晶") and is_pity:
        wish = 0
        pity += 1
        continue
    wish += 1

print(f"抽数 {N:,}")
print(f"神谕之石总产出 {stones:,} → 每抽 {stones/N:.4f} 石，每 100 抽 {stones/N*100:.2f} 石")
print(f"石命中率 {stone_hits/N*100:.3f}%  保底触发 {pity_hits/N*100:.2f}% ({N/pity_hits:.1f}抽/次)")
print(f"保底中出石概率 {pity_stone_hits/pity_hits*100:.1f}%")
print(f"金币回收 {gold_gained:,} → 每抽 {gold_gained/N:.0f}")
for k, v in cnt.most_common():
    print(f"  {k}: {v/N*100:.2f}%")
gold_per_stone = 10000 * N / stones
print(f"折合每石 {gold_per_stone:,.0f} 金币（按单抽1万；5连/50连 9500 → {9500*N/stones:,.0f}）")
