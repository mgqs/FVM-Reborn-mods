# QQ 号校验 / 授权体系方案

> 适用版本：FVM_Reborn_makk（GMS 2026.0.0.16，Windows only）
> 现状前提：已有自建后端 `https://fvm-reb.top`（`/api/items` 在线地图在用）、可用原生扩展通道（`FvmNativeSupport.dll`）、成熟的 `http_request` + `Other_62`（Async HTTP）模式。

---

## 0. 先定清楚要什么

"加 QQ 号校验"有三种完全不同的诉求，别混着做：

| 诉求 | 真正需要的能力 | 推荐路线 |
|---|---|---|
| **A. 白名单授权**：只有群友 / 授权玩家能玩 | 证明「这个 QQ 号是真人且已授权」 | 群机器人绑定（方案一） |
| **B. 账号体系**：云存档、排行、跨设备同步 | 稳定的用户唯一 ID | 自建账号，QQ 只作身份来源（方案二） |
| **C. 防盗版防破解** | 无法达成，只能抬高门槛 | 服务端绑定 + 高价值功能上云（配合 A/B） |

先回答这个问题再动手，否则会做出"能用但没意义"的东西。

---

## 1. 为什么不要直接接「QQ SDK」

- 腾讯**没有 PC 端可用的 GMS QQ 登录 SDK**。`TencentOpenAPI` 是移动端；PC 只有 QQ 互联的 Web 授权。
- QQ 互联个人开发者需资质审核，回调域名需 ICP 备案，且**只返回 openid，拿不到 QQ 号**——想显示"已绑定 QQ：12345678"这类功能本身就做不到。
- GMS 没有内建 WebView。要在游戏内嵌授权页，得自己写 C++ 扩展包 WebView2，成本远超收益。
- 硬包 `TencentOpenAPI` 到 DLL 里是最差路径：库体积大、签名校验严、失败静默。

**结论**：QQ 只作为"身份来源"，真正的校验逻辑全部放在你自己的服务器 `fvm-reb.top` 上。客户端永远只跟自己的服务器说话。

> **如果你不想用服务器**，直接跳到第 11 章「无服务器方案」。那条路不依赖任何后端，代价是放弃服务端权威（第 2 章的前提），目标从"验证身份"降级为"控制分发"。

---

## 2. 核心安全模型（这一节决定方案成不成立）

**客户端不可信。** GML 编成 VM 字节码或 YYC 都能被 UndertaleModTool 改；自带 DLL 也能被同名替换。所以：

- ❌ 任何"客户端判断 QQ 号对不对"的设计 = 没做。包括把授权 QQ 列表写进 `save_data`、用 `HMAC(qq, 内置密钥)` 本地比对。
- ✅ 客户端只做两件事：展示登录态、带着 token 发请求。
- ✅ 服务端是唯一权威，签名密钥永不出服务器。

**token 格式**：

```
payload = {qq, hwid, exp}
token   = base64url(json(payload)) + "." + hex(HMAC_SHA256(server_secret, base64url(json(payload))))
```

客户端不解密、不验证，只存取和透传。服务端每次收到请求先验签 + 查 `exp` 和 `banned`。

**这是本方案唯一不能妥协的地方。**

---

## 3. 三条路线对比

| | 方案一 群机器人绑定 | 方案二 QQ 互联 Web 授权 | 方案三 纯白名单 |
|---|---|---|---|
| QQ 号可信度 | 高（腾讯侧确认发送者） | 中（只给 openid，无 QQ 号） | 无（玩家自填） |
| 资质 / 备案 | 不需要 | 需要（开发者审核 + 域名备案） | 不需要 |
| 玩家成本 | 需加群，群内发一条命令 | 浏览器跳出授权 | 填个数字 |
| 服务端改动 | 4 个接口 | 6 个接口 + OAuth 回调 | 2 个接口 + 静态表 |
| 主要风险 | 依赖机器人常驻 | 审核不通过 / 接口收紧 | 改内存就能过 |
| 适用 | 授权制、内测、防外传 | 想要账号体系与昵称头像 | 赞助授权、临时封测 |

**推荐：方案一**。同人/独立游戏圈最常用、门槛最低、可信度反而最高。

---

## 4. 方案一：QQ 群机器人绑定（推荐）

### 4.1 交互流程

```
游戏                      fvm-reb.top                 QQ 群 / 机器人
 │                              │                            │
 │ ①POST /api/auth/bind-code    │                            │
 │   {hwid}                     │                            │
 ├─────────────────────────────>│  生成 6 位码，TTL 10min     │
 │<─────────────────────────────┤  {code:"418273"}           │
 │  显示「请在群内发送：         │                            │
 │        #绑定 418273」         │                            │
 │                              │                            │
 │                              │  ②玩家发 "#绑定 418273"     │
 │                              │<───────────────────────────┤
 │                              │  ③POST /api/auth/bind       │
 │                              │   {code, qq, sign}          │
 │                              │   sign=HMAC(bot_key,...)    │
 │                              ├───────────────────────────>│
 │                              │  绑定 qq↔hwid，签发 token   │
 │                              │                            │
 │ ④GET /api/auth/poll?code=…   │                            │
 │   （每 2s 轮询）              │                            │
 ├─────────────────────────────>│                            │
 │<─────────────────────────────┤  {state:"ok", token}       │
 │  落盘 auth.dat               │                            │
```

关键点：**③ 的 QQ 号来自机器人收到的 `event.user_id`，玩家无法伪造**——这就是"QQ 号校验"的真正实现方式。游戏客户端从头到尾没碰过 QQ 号。

### 4.2 服务端接口

```
POST /api/auth/bind-code
  in : {hwid}
  out: {code, expire}                       // code 6 位数字，一人一码，重复请求复用未过期码

POST /api/auth/bind                         // 仅机器人调用，校验 bot_key 签名
  in : {code, qq, sign}
  out: {ok:true, msg}

GET  /api/auth/poll?code=xxx
  out: {state:"waiting"|"ok"|"expired", token?, qq?}

POST /api/auth/verify                       // 业务接口统一先过这个
  in : {token}
  out: {valid, qq, exp}
```

表结构（SQLite / MySQL 均可）：

```sql
CREATE TABLE auth_user (
  qq        BIGINT PRIMARY KEY,
  hwid      TEXT,            -- 绑定机器指纹，空 = 未绑机
  token     TEXT,
  exp       INTEGER,         -- unix 秒
  banned    INTEGER DEFAULT 0,
  created   INTEGER,
  last_seen INTEGER
);
CREATE TABLE auth_code (
  code      TEXT PRIMARY KEY,
  hwid      TEXT,
  expire    INTEGER,
  used      INTEGER DEFAULT 0
);
```

`/api/items` 这类现有接口加上可选 `token` 参数，验签通过才返回完整数据即可——高价值功能挂服务端，比客户端拦截有用得多。

### 4.3 机器人侧

现有群机器人（NoneBot2 / 云崽 / Koishi 都行）加一个命令：

```
#绑定 418273
```

处理逻辑：取 `event.user_id` → 调 `/api/auth/bind`，`sign = HMAC_SHA256(bot_key, code + qq)` → 按返回结果回复"绑定成功，回到游戏即可开始"或"验证码已过期"。

这一步的代码量与一个普通群管理命令相当。

---

## 5. 方案二：QQ 互联 Web 授权（若确实想要账号体系）

- 服务端建 `/auth/qq`：重定向到 QQ 授权页，`state` 存会话。
- 回调 `/auth/qq/callback`：用 `code` 换 `access_token`（appid/appkey 只在服务端）→ 拿 `openid` + 昵称头像 → 签发游戏 token，落到 `auth_session` 表。
- 客户端：`url_open("https://fvm-reb.top/auth/qq?state=" + state)` → 每 2s 轮询 `/api/auth/poll?state=xxx` 拿 token。
- **不需要 WebView**，用系统浏览器 + 轮询即可，省掉整个 C++ 扩展。

注意：拿不到 QQ 号，只有 openid；且授权页在浏览器里跳出，体验割裂。仅当"必须显示 QQ 昵称头像"时才值得走。

---

## 6. 方案三：纯白名单（最弱，但最快）

玩家输入 QQ 号 → `POST /api/auth/wl {qq, hwid}` → 服务端查白名单表 → 下发 token。
适合你手工维护一份赞助/内测名单。**只防手改存档，不防内存修改，别对外宣称是"防盗版"。**

---

## 7. 客户端落地（GML）

### 7.1 新增 `scripts/auth_client/auth_client.gml`

```gml
#macro kAuthApiBase "https://fvm-reb.top"

function AuthClient() constructor {
    self.token      = "";
    self.qq         = 0;
    self.state      = "idle";   // idle / requesting / waiting / ok / failed
    self.code       = "";
    self.req_id     = -1;
    self.poll_timer = 0;
    self.poll_url   = "";
    self.expire_at  = 0;

    static token_path = function() {
        var _dir = global.native_util.get_path_in_local_appdata("\\FVM_Reborn_makk");
        return _dir + "\\auth.dat";
    }

    static headers = function() {
        var _h = ds_map_create();
        ds_map_add(_h, "User-Agent", "FVM-Reborn");
        ds_map_add(_h, "Content-Type", "application/json");
        ds_map_add(_h, "Accept", "application/json");
        return _h;
    }

    static hwid = function() {
        // 弱指纹，纯 GML，不上 DLL，避免杀软误报
        var _a = environment_get_variable("COMPUTERNAME");
        var _b = environment_get_variable("PROCESSOR_IDENTIFIER");
        var _c = environment_get_variable("USERNAME");
        return string_upper(md5_string_utf8(_a + "|" + _b + "|" + _c));
    }

    static request_bind_code = function() {
        var _body = json_string({hwid: hwid()});
        var _h = headers();
        self.req_id = http_request(kAuthApiBase + "/api/auth/bind-code", "POST", _h, _body);
        ds_map_destroy(_h);
        self.state = "requesting";
        return self.req_id;
    }

    static start_poll = function(_code) {
        self.code = _code;
        self.poll_url = kAuthApiBase + "/api/auth/poll?code=" + string(_code);
        self.poll_timer = 0;
        self.state = "waiting";
    }

    static save_token = function(_token, _qq) {
        self.token = _token;
        self.qq = _qq;
        self.state = "ok";
        var _buf = buffer_create(1024, buffer_grow, 1);
        buffer_write(_buf, buffer_text, json_string({token: _token, qq: _qq}));
        buffer_save(_buf, token_path());
        buffer_delete(_buf);
    }

    static load_token = function() {
        var _p = token_path();
        if (!file_exists(_p)) return false;
        var _buf = buffer_load(_p);
        var _s = buffer_read(_buf, buffer_text);
        buffer_delete(_buf);
        var _j = json_parse(_s);
        if (!is_struct(_j) || !variable_struct_exists(_j, "token")) return false;
        self.token = _j.token;
        self.qq = _j.qq;
        self.state = "ok";
        return true;
    }

    static clear_token = function() {
        self.token = "";
        self.qq = 0;
        self.state = "idle";
        var _p = token_path();
        if (file_exists(_p)) file_delete(_p);
    }
}
```

### 7.2 轮询与响应处理

复刻 `obj_update_checker_btn/Other_62.gml` 的写法，在独立的 `obj_auth_gate` 的 **Async HTTP** 事件里分发：

```gml
var _id = async_load[? "id"];
var _status = async_load[? "http_status"];
var _result = async_load[? "result"];
if (_id != global.auth.req_id) exit;

if (_status != 200) { global.auth.state = "failed"; exit; }
var _j = json_parse(_result);

if (global.auth.state == "requesting") {
    if (!is_struct(_j) || !variable_struct_exists(_j, "code")) { global.auth.state = "failed"; exit; }
    global.auth.start_poll(_j.code);
}
else if (global.auth.state == "waiting") {
    if (_j.state == "ok") global.auth.save_token(_j.token, _j.qq);
    else if (_j.state == "expired") global.auth.state = "failed";
    // waiting 保持状态，Step 里继续发下一次轮询
}
```

Step 里自己计时（`http_request` 没有超时参数，必须自己兜底）：

```gml
if (global.auth.state == "waiting") {
    self.poll_timer++;
    if (self.poll_timer >= 120) {        // 60fps 下 2 秒
        self.poll_timer = 0;
        var _h = AuthClient.headers();
        global.auth.req_id = http_request(global.auth.poll_url, "GET", _h, "");
        ds_map_destroy(_h);
    }
    if (current_time > self.expire_at) global.auth.state = "failed";
}
```

### 7.3 挂钩点

| 位置 | 改动 |
|---|---|
| `room_init` 末尾 / `room_menu` 的 Create | `global.auth = new AuthClient(); global.auth.load_token();` |
| `room_menu` | 未授权时 `instance_create_depth(..., obj_auth_gate)`，`is_paused = true`（照抄 `obj_hex_panel` 的暂停套路） |
| 战斗入口（`obj_battlestart_button` 的 Mouse 事件） | 二次检查 `global.auth.state == "ok"`，防止绕过界面 |
| 在线地图 / 后续联机 | 请求体带 `token`，服务端验签 |

---

## 8. 本项目特有的坑（务必先看）

1. **字体缺字**：登录页文案要先比对 `font_yuan` / `font_hei` 的字形表。「绑 码 验 证 授 权 期 限 剩 余」这类字很容易漏（`font_hei` 已知缺 `羁绊炖煨撮薪阈噬`）。新增 UI 文案前按 `docs/字体与字形维护.md` 走 `tools/font_fill.py`。
2. **新建对象要注册三处**：`objects/obj_auth_gate/`、`.yyp` 的 `resources`、`folders/*.yy` 的 `listItems`（最后一项不带尾逗号），否则对象不生效。
3. **`.yy` 尾逗号**：改 `WindowsNative.yy` 时注意，标准 JSON 解析会失败。
4. **加原生函数的三处同步**：C++ 导出 + `WindowsNative.yy` 的 `functions` 数组 + 重新编译 `FvmNativeSupport.dll`，且发行包必须带上新 DLL。**如果将来有 `data.win` 补丁式分发，走 DLL 的方案会直接失效**——这也是本方案 HWID 坚持先用纯 GML 的原因。
5. **杀软误报**：自写 DLL 做硬件指纹 + 联网校验，在国内用户环境里极容易被 360 / 火绒拦。HWID 优先用 `environment_get_variable` 弱指纹。
6. **离线降级必须有**：网络失败 / 服务器挂掉时，玩家必须还能进游戏。建议"离线宽限期"（token 过期后仍允许 7 天单机），否则断网玩家第一时间来骂。
7. **`http_request` 无超时**：必须自己用 `current_time` 计时，否则一次失败请求会卡 30 秒以上。

---

## 9. 推进顺序建议

1. 服务端先上 `/api/auth/bind-code` + `/api/auth/bind` + `/api/auth/poll`，用 `curl` 跑通全流程（不碰游戏代码）。
2. 群机器人加 `#绑定` 命令，跑通"码 → QQ"的闭环。
3. GML 侧做 `AuthClient` + `obj_auth_gate`（先做纯展示，不拦截），确认 HTTP 链路通。
4. 接入 `obj_battlestart_button` 做拦截。
5. 最后再把 token 挂到在线地图等已有接口上，让"授权"产生实际价值。
6. 全局兜底：离线宽限期 + 失败重试上限 + 明确错误文案。

---

## 10. 一句话总结

不要接 QQ SDK。用「服务端签发 token + 群机器人确认 QQ 号 + 客户端只透传」的三段式，成本最低、可信度最高、且不会被 GMS 的能力边界卡住。防破解只能靠"高价值功能上云"，本地拦截只是体验层的装饰。

---

# 11. 无服务器方案（纯离线授权码）

> ⚠️ **本章是过程稿，代码已作废。** 它描述的是「码里编 QQ 号」的 FVM1/FVM2 形态——那条路在游戏端绑不住人（官方机器人只给 openid，游戏更不知道当前是谁），而且「别人拿到我的码」照样能用。**实际实现见第 12 章的 FVM4（签名绑机器指纹）**。本章保留是为了记录取舍过程，照抄代码会跑不通。

> 前提：不打算用 `fvm-reb.top`、不写后端、不买域名、不做备案。

## 11.0 先接受三个代价

| 放弃的能力 | 后果 |
|---|---|
| 服务端权威 | 校验逻辑在客户端，**patch 一行 `return true` 即可绕过** |
| 远程封禁 | 发现有人外传，只能换 secret + 发新版，老用户要重新授权 |
| 在线统计 / 云存档 | 拿不到在线数、绑定数、作弊记录 |

所以这个方案的目标**必须改**：不是"验证身份"，而是「**控制分发范围 + 抬高门槛 + 让破解版内容残缺**」。别对外宣称"防盗版"，它做不到。

## 11.1 关键技巧：让群机器人当验证通道，玩家手工搬运授权码

第 4 章里机器人是"把 QQ 号回调给你服务器"。无服务器时，把这一步改成「**机器人自己算出授权码，直接回复给玩家，玩家复制进游戏**」。

```
玩家                      QQ 群机器人              游戏客户端
 │                            │                       │
 │ ① 群内发 "#授权"            │                       │
 ├───────────────────────────>│                       │
 │                            │ 读 event.user_id      │
 │                            │ （腾讯侧确认，不可伪造）│
 │                            │ 本地算 md5 签名        │
 │ ② 机器人回复：              │                       │
 │    FVM-7CLZI-17D85D2486    │                       │
 │<───────────────────────────┤                       │
 │                                                    │
 │ ③ 复制粘贴进游戏 ──────────────────────────────────>│
 │                                                    │ ④ 用内置 secret
 │                                                    重算 md5 比对
 │                                                    通过 → 写 auth.dat
```

**这条路里没有任何服务器**：机器人是现成的 NoneBot2 / 云崽实例（挂你自己电脑或免费托管），不监听公网、不提供 API、不需要域名和备案。腾讯侧依然是 QQ 号的唯一来源，所以"QQ 号真实性"这一点没有丢。

## 11.2 授权码规格

格式：`FVM-<qq36>-<sig10>`

| 段 | 含义 |
|---|---|
| `FVM` | 前缀，便于识别和版本扩展（以后可 `FVM2-`） |
| `qq36` | QQ 号转 36 进制（大写），缩短且不直观看得出 QQ 号 |
| `sig10` | `md5("FVM1\|qq\|period\|SECRET")` 的前 10 位十六进制（大写） |

`period` 为 `0` 表示永久码；填年份（如 `2026`）则该年份的码才有效——**这是唯一能"让旧码自然过期"的手段**，建议年度授权用这个。

签发工具：`tools/qq_auth.py`（已可用，标准库，无第三方依赖）

```bash
python tools/qq_auth.py issue 12345678          # FVM-7CLZI-17D85D2486
python tools/qq_auth.py issue 12345678 --year 2026
python tools/qq_auth.py batch qqlist.txt        # 批量，输出 qq,code 两列
python tools/qq_auth.py verify FVM-7CLZI-17D85D2486
python tools/qq_auth.py gml                     # 打印要贴进 GML 的宏
```

改成自己的 `SECRET` 后跑一次 `selftest` 确认无误。

## 11.3 GML 验签实现

```gml
// scripts/auth_client/auth_client.gml
#macro kAuthPrefix "FVM"
#macro kAuthSecret "CHANGE_ME_TO_A_LONG_RANDOM_STRING_2026"
#macro kAuthPeriod "0"          // 与脚本 --year 保持一致，否则全部验签失败

function auth_expected_sig(_qq) {
    var _raw = "FVM1|" + string(_qq) + "|" + kAuthPeriod + "|" + kAuthSecret;
    return string_upper(string_copy(md5_string_utf8(_raw), 1, 10));
}

function auth_qq_from_base36(_text) {
    var _out = 0;
    var _n = string_length(_text);
    for (var i = 1; i <= _n; i++) {
        var _ch = string_char_at(_text, i);
        var _idx = string_pos(_ch, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ") - 1;
        if (_idx < 0) return -1;
        _out = _out * 36 + _idx;
    }
    return _out;
}

/// @returns {Real} QQ 号；校验失败返回 -1
function auth_verify_code(_code) {
    _code = string_upper(string_trim(_code));
    var _parts = string_split(_code, "-");
    if (array_length(_parts) != 3) return -1;
    if (_parts[0] != kAuthPrefix) return -1;
    var _qq = auth_qq_from_base36(_parts[1]);
    if (_qq <= 0) return -1;
    if (auth_expected_sig(_qq) != _parts[2]) return -1;
    return _qq;
}
```

> 为什么这里用 `md5` 而不是第 2 章的 HMAC-SHA256：GMS 没有内建 HMAC，纯客户端场景下"secret 泄露"和"算法被还原"的结局一样，HMAC 的额外强度买不到任何东西，而 md5 是内建的、零依赖。别为此去写 150 行 SHA256。

绑定成功后写盘，复用第 7 章的 `save_token` 思路：

```gml
global.auth_qq = auth_verify_code(input_text);
if (global.auth_qq > 0) {
    global.auth.save_token("offline|" + string(global.auth_qq), global.auth_qq);
} else {
    show_notice("授权码无效", 90);
}
```

## 11.4 输入界面

- 复用现成的 `SearchBox` 对象（`OnlineMapGUI` / `LaboratoryGUI` 都有先例），它已处理粘贴和输入法；
- 或者偷懒用 `get_string_async`，但中文输入法和粘贴体验差，不推荐；
- **字号与字形**：新增文案里的「授权码 / 验证 / 绑定 / 无效」必须比对字形表，`font_hei` 已知缺字，按 `docs/字体与字形维护.md` 补。

## 11.5 比"拦截启动"更有效的做法：内容分级授权

**别把校验卡在启动口。** 那里最容易 patch，而且一次误判就让人进不去游戏，差评成本极高。

改成「**破解版内容残缺**」：

```gml
// 在注册新增卡片 / 关卡 / 模式的入口处
if (global.auth_qq > 0) {
    // v2.5 新增：青涩柿柿、旋风牛、12周年饮料、蛋蛋兔、黯然销魂饭、烈火虎…
}
```

比起在 `obj_battlestart_button` 里 `if (!auth) exit;`，这种散落在业务逻辑里的判断**难找、难一次改干净**，而且破解者拿到的是缺内容版本，传播价值自然下降。

代价：改动点分散，记得每加一个新内容都问一句"这个要不要挂授权"。

## 11.6 降低 secret 泄露伤害

1. **别写成单个字符串常量**。`strings` 或十六进制扫描一扫就中。拆成 3 段放在不同脚本里，运行时 `string_concat` 拼接。
2. **别用有意义的串**。`FVM_REBORN_2026` 这类会被字典猜中。
3. **版本化**：`kAuthSecretV2`，泄露就换 + 发新版；旧码在同一次更新里失效。
4. **年度 period**：即便 secret 没泄露，也能让授权每年回群续一次。
5. 有个反直觉但有效的点：把 secret 藏进**看起来无关的**既有常量里（比如某个调色板字符串或字体名数组），比专门起个 `auth_secret` 变量更安全。

## 11.7 如果哪天改主意（零运维中间地带）

- **GitHub Pages 放加密的授权列表**：只是静态文件，仍然"没有服务器"，但你能远程改名单（`http_request` 拉取 + 本地解密），能实现远程封禁。
- **Cloudflare Workers 免费层**：10 万请求/天，无备案要求，部署 5 分钟——严格说这是 serverless，但不用运维。

这两条都保留第 2 章的服务端权威，值得在离线方案跑通后再评估。

## 11.8 无服务器方案的推进顺序

1. 改 `tools/qq_auth.py` 的 `SECRET`，跑 `selftest`。
2. 把 `gml` 命令输出的宏贴进 `scripts/auth_client/auth_client.gml`。
3. 群机器人加 `#授权` 命令，内部调 `qq_auth.py` 的签名逻辑（或直接把脚本 import 进去）。
4. 游戏里做输入框 + `auth_verify_code()` + 绑定落盘，先不拦截任何东西，只显示"已授权 QQ：xxx"。
5. 挑 3~5 个新增内容挂 `if (global.auth_qq > 0)`，观察反馈。
6. 全部跑顺后再决定要不要把战斗入口也加上（可选，收益低）。

---

# 12. 固定码池 + 反编译封装（最终选型）

> 需求：我自己预先准备一批固定的授权码，机器人发其中一个，绑定 QQ，一个 QQ 只发一次。

## 12.0 池子可以有，但只能待在机器人侧

「在项目里打包一份授权码文件」和「机器人从池子里发码」是两件事，前者要命、后者没问题：

| | 池子打包进游戏 | 池子在机器人侧（本方案） |
|---|---|---|
| 游戏里有什么 | **全部码明文** | 只有验签算法 |
| 被 dump 后 | 全部码泄露，人人可激活 | 拿不到任何码 |
| 加码 / 改码 | 要重新发游戏 | 改池子文件即可，游戏不动 |
| 校验方式 | 查表 + 标记已用 | 算签名比对 |

**做法**：池子里的码是你定的 ID，机器人发放时**补一个签名**发给玩家。游戏只验签名，不查表。

```
tools/codes_pool.txt          机器人从这里取
  8F3K2M9Q          ──┐
  L2P0X7RT            │  发放时补签名
  ...                 ↓
                  FVM4-8F3K2M9Q-1A2B3C4D-1D85D2486   ← 玩家看到、游戏验签
```

这样码依然是「你预先固定的那批」，但游戏里没有任何码表，加码不用发新版。

## 12.1 「别人拿到我的码也用不了」由谁保证

先说清楚哪件事做不到：**「码被用过一次就全局失效」在纯离线下不可能。**
「谁用过」是需要第三方存储的事实，玩家 A 和玩家 B 的电脑之间没有通道，游戏端也不可能去查你的账本。

但你真正要防的是另一件事：**别人拿到我的码能不能用。** 这个有解。

关键在于换掉「绑谁」：

| | 想绑 QQ 号 | 实际能绑的 |
|---|---|---|
| 机器人端 | 有 openid | ✔ |
| 游戏端 | **没有**（官方只给 openid，游戏更不知道当前是谁） | ✘ |
| 机器指纹 | 机器人端没有 | 游戏端**有** ✔ |

所以绑**机器指纹**：机器人把机器码一起签进码里，游戏端用自己的 `auth_hwid()` 比对。签名保证机器码改不了，比对保证只有那台机器能过。

| 约束 | 由谁强制 | 能否绕过 |
|---|---|---|
| 一个码只能在一台机器上用 | 签名签了机器码 + 游戏端比对本机 `auth_hwid()` | 不能（改机器码段 → 签名失效） |
| 一台机器只有一个有效码 | 账本 `hwid` 主键 | 不能 |
| 一个池子码只发一次 | `code_id` UNIQUE | 不能 |
| 码是真是假 | 签名，本地重算 md5 | 不能 |
| 远程吊销已发出的码 | `revoke <机器码>` 只删账本记录，玩家手上已存的码仍能过 | **纯离线无解** |

**一句话：能防转发，不能远程作废。** 这和「防盗版」是两件事，别混着对外说。

## 12.2 码格式与工具

```
FVM4-8F3K2M9Q-1A2B3C4D-1D85D2486
     └──ID───┘ └机器码┘ └─签名──┘
```

| 段 | 说明 |
|---|---|
| `FVM4` | 格式版本（`FVM3` 是只绑 QQ 的旧格式，已作废） |
| 码ID | 池子里的一行，4~20 位，字符集 `23456789ABCDEFGHJKLMNPQRSTUVWXYZ`（排除 0/O/1/I，玩家不会看错） |
| 机器码 | 本机指纹 md5 前 8 位十六进制 = `md5(COMPUTERNAME\|PROCESSOR_IDENTIFIER\|NUMBER_OF_PROCESSORS)` |
| 签名 | `md5("FVM4\|码ID\|机器码\|SECRET")` 前 10 位大写十六进制 |

机器码**只取系统名 + CPU 型号**，不掺用户名——改个用户名就让码失效太坑玩家。代价是换电脑 / 重装系统 / 改计算机名后识别码会变，需要重新领一次（账本按 hwid 记，领新码不消耗额外逻辑）。

`tools/qq_auth.py`（标准库，无第三方依赖）：

```bash
python tools/qq_auth.py poolgen 500              # 生成 500 个随机码ID 追加进池子
python tools/qq_auth.py pool                     # 看池子用了多少、下一个发哪个
python tools/qq_auth.py issue 12345678 1A2B3C4D  # 给这台机器发码
python tools/qq_auth.py ledger                   # 机器码 ↔ 用户 ↔ 码
python tools/qq_auth.py revoke 1A2B3C4D          # 作废某台机器（下次要用识别码重领）
python tools/qq_auth.py verify <码>              # 看这个码绑的是哪台机器
python tools/qq_auth.py gml                      # 生成要贴进 GML 的宏
python tools/qq_auth.py selftest
```

**池子可以自己编辑**：`tools/codes_pool.txt` 一行一个 ID，想用 `VIP0001`、`NEZHA88` 这种好记的都行，只要在字符集内。发放时自动补机器码和签名。

**一个 QQ 最多绑 2 台机器**（`MAX_DEVICES_PER_UID`，默认 2），防止有人反复换识别码刷码。第 3 台起返回 `TooManyDevices`，机器人回「已经绑满 2 台，不能再领新码」。

这条拒绝是**对玩家硬性的、没有自助解绑**：玩家在机器人这里得不到任何「换一台」的办法。理由是把限额做成橡皮筋，等于没有限额。

管理侧走**仅私聊、仅白名单**的解绑（2026-10-29 加）：

| 命令 | 谁能用 |
|---|---|
| `/我是谁` | 任何人（只说给他自己） |
| `/管理绑定 <口令>` | 口令正确且尚无人认领 |
| `/解绑 <识别码或码ID>` `/解绑账号 <openid前缀>` `/绑定列表` | 仅管理员 |

**为什么是口令而不是 QQ 号**：官方机器人事件里只有 `openid`，没有任何接口能换回 QQ 号，所以「必须是 1017443780」无法直接判定。改成一次性口令认领——把口令私下发给本人，他私聊发一次 `/管理绑定 <口令>`，机器人把他的 openid 写入账本 `admins`，口令随即失效；`admins` 非空后任何再认领都被静默拒绝，从此锁死在这一个账号。口令打包时被剔除，云端只从 `AUTH_ADMIN_TOKEN` 读。

非管理员发这些命令**完全静默**（不是「无权限」），群里 @ 一律忽略——`/绑定列表` 会把别人的 openid 贴到公屏。每次解绑写进 `audit`（保留最近 200 条）。

## 12.3 密钥和池子都不能进公开仓库

这个仓库是公开的（GPL）。**池子 + 密钥同时泄露 = 任何人都能自己造码**，连逆向都省了。

| 文件 | 处理 |
|---|---|
| `tools/codes_pool.txt` | 已 `.gitignore` |
| `tools/qq_auth.db` | 已 `.gitignore`（含玩家 QQ 号，泄露是隐私事故） |
| `tools/auth_secret.txt` | 已 `.gitignore`。密钥优先从这里读，缺失才用代码里的占位符 |

`auth_client.gml` 里的 `kAuthSecretA/B/C` 是提交进仓库的。当前**已按「接受密钥入库」执行**（2026-10-29 写入 40 位随机密钥，池子已扩容到 4000 个）：

| | 现状 |
|---|---|
| `tools/auth_secret.txt` | 40 位随机串，`.gitignore`，**这是唯一真值来源** |
| `auth_client.gml` 三段宏 | 已由 `gml` 命令写入，与上面一致 |
| `tools/codes_pool.txt` | 4000 个码 ID（32⁸ ≈ 1.1 万亿空间，容量只是预置量） |
| `tools/qq_auth.db` | 空（未发放） |

判断：密钥最终必然存在于游戏二进制里，藏它只增加一步逆向。**真正的门槛是 12.4 的 YYC + 拆段 + 后续下沉 DLL**。

如果以后想改成「密钥不进仓库」，流程是：

1. 提交前把 `auth_client.gml` 的三段宏还原成 `CHANGE_ME_A/B/C`
2. 本地构建前再跑一次 `python tools/qq_auth.py gml` 写回去

**轮换密钥（换新 SECRET）的后果**：所有已发出的码同时失效，玩家必须重新领。只在发大版本、或确认密钥外泄时做，步骤：删 `tools/auth_secret.txt` → 重新 `poolgen` 与否随意（池子 ID 可复用）→ `gml` 写进 GML → 重新编译发布。旧账本 `tools/qq_auth.db` 要一并删掉，否则老机器会被判成「已发过」而拿到验不过的旧码。

## 12.4 反编译封装：按性价比排序

### 12.4.1 第一优先级：用 YYC 构建

- **VM 模式**产出 `data.win` 字节码，UndertaleModTool 能反编译出接近源码的 GML。
- **YYC 模式**先编 C++ 再编机器码，控制流难以还原。

README 里已有 YYC 构建路径（VS + MSVC v142）。**只做这一件事就挡住 80% 想改校验的人**，且零成本。

### 12.4.2 别把密钥写成一整条常量

单条 `secret = "xxxx"` 会被 `strings` / 十六进制扫描直接命中。已实现为三个宏运行时拼接，`gml` 子命令自动切段。

### 12.4.3 关键校验下沉到 DLL（项目已有通道）

`FvmNativeSupport.dll` 的 VS 工程在仓库里。把 `auth_expected_sig()` 搬进 C++，GML 只剩一句 `native_auth_verify(code)`。反编译只能看到外部调用。配合 `IsDebuggerPresent` / `CheckRemoteDebuggerPresent` 能劝退动态调试。

**代价**：要发新 DLL、杀软误报上升、且与 `data.win` 补丁式分发互斥。**建议先只做 12.4.1 + 12.4.2。**

### 12.4.4 判断逻辑打散

别集中写成 `if (!auth_ok()) exit;`（一改就过）。改成把新增内容挂在授权上：

```gml
// 卡片注册处
if (auth_ok()) { register_card("qingsesese"); }
```

散落在业务逻辑里，难找难改清；破解版拿到的是**内容残缺**的版本，传播价值下降。

### 12.4.5 不推荐加壳

VMProtect / Themida 国内杀软几乎必拦，玩家第一反应是"有病毒"。收益和口碑不成比例。

## 12.5 已落地文件

| 文件 | 状态 | 说明 |
|---|---|---|
| `tools/qq_auth.py` | ✅ | 池子生成 / 发放（绑机器指纹）/ 账本 / 作废 / 验签 / 生成 GML 宏 |
| `tools/codes_pool.txt` | 运行时生成 | 你的码池，可手编 |
| `scripts/auth_client/auth_client.gml` | ✅ | 验签 + 机器码比对 + 本地绑定 + seal 防手改 |
| `bots/qq_auth_bot/` | ✅ | QQ 官方机器人（WS 长连接），`#授权 <识别码>` 发码 |
| `.gitignore` | ✅ | 池子 / 账本 / 密钥全部排除 |

`auth_client.gml` 接口：

```gml
auth_init()            // obj_game_init / room_menu 的 Create 里调一次
auth_hwid()            // 本机识别码，8 位大写十六进制
auth_hwid_text()       // 展示形式 "1A2B-3C4D"，面板上给玩家复制
auth_bind(_code)       // 0=成功 1=码无效 2=这码是给别的机器的
auth_verify_code(_c)   // 纯校验，返回 {ok, code_id, hwid, reason}
                       // reason: "" / "format" / "sig" / "machine"
auth_ok()              // Bool
auth_label()           // "已授权 · 凭证 M9Q"，未授权返回 ""
auth_clear()           // 解绑（调试用）
```

`auth_load()` 在开机时也会走一遍 `auth_verify_code()`，所以换过机器之后旧的 `auth.dat` 会自动失效、`global.auth_machine_changed` 置真，玩家重新领码即可。

`auth_init()` 必须在 `global.native_util` 初始化之后，`auth_file_path()` 依赖它。

## 12.6 机器人（QQ 官方机器人平台）

见 `bots/qq_auth_bot/README.md`。要点：

| 事项 | 做法 |
|---|---|
| 接入方式 | **WebSocket 长连接**（`/gateway` → `wss://`），主动出站，**不需要公网 IP / 域名 / 备案** |
| 凭据 | AppID + AppSecret 换 `access_token`（约 2 小时，脚本自动续） |
| 身份主键 | **openid**（不是 QQ 号），账本 `uid` 字段，一个号一条 |
| 事件 | `C2C_MESSAGE_CREATE`（私聊）、`GROUP_AT_MESSAGE_CREATE`（群 @） |
| 回复 | 必须带 `msg_id` 被动回复，`msg_seq` 递增，5 分钟内有效 |
| 掉线 | 连续 5 次失败即停止，**别写无条件重启的守护脚本** |
| 兜底 | 机器人挂了用 `python tools/qq_auth.py issue <uid>` 手工发码 |

### 12.6.1 为什么是官方平台，不是 NapCat

原本按 NapCat 写的版本已废弃。改口的原因不是"官方更好"，而是**用户实际已经建好的是官方机器人**，而两者协议完全不兼容。对比：

| | NapCat 等第三方协议端 | QQ 官方机器人 |
|---|---|---|
| 身份 | 真实 QQ 号 | openid |
| 需要服务器 | 否 | **否**（WS 出站长连接） |
| 账号风险 | 有封禁风险（腾讯视作外挂） | 合规 |
| 能不能显示「QQ：12345678」 | 能 | **不能** |
| 覆盖面 | 任何群 | 个人主体：只能自己的群 + 体验白名单 |

**关键判断：openid 够用。** 本项目要的是"一个账号只发一次码"，openid 是腾讯侧给的稳定唯一标识，伪造不了，效果与 QQ 号等价。损失的只是"游戏里显示 QQ 号"这个展示需求——而 12.2 的码格式本来就已经不含 QQ 号了。

### 12.6.2 玩家怎么领

```
① 游戏 → 右上角「授权」按钮 → 面板显示「本机识别码 1A2B-3C4D」，点一下复制
② 私聊（或群里 @）机器人：#授权 1A2B-3C4D
③ 机器人回码 → 粘贴进游戏 → 确认绑定
```

`#授权` 后面不带识别码时，机器人会回一段领取说明，不会直接发码——**这是刻意的**，因为不带机器码的码任何人都能用。

**群里 @ 也可以发码**（`ALLOW_GROUP_ISSUE` 默认 `1`）：码已经锁死机器，公屏发也拿不走，只是不太雅观。想只走私聊设成 `0`。

同一个识别码再发 `#授权`（或 `#查码`）返回同一个码，不消耗新池子 ID。

### 12.6.3 平台硬限制（代码绕不过去）

2026-10 查证：

- **被动回复 5 分钟窗口**，且一条消息最多回 5 次（`msg_seq` 递增规避）。
- **不支持主动推送**：机器人不能主动找人，只能等玩家先发消息。
- **加群受主体等级限制**（2026-10 查证，两处官方文档口径不一致，按灰度现状理解）：
  - 未认证：机器人仅管理员可用，只能加到**自己是群主**的群；
  - 个人认证：新版产品介绍页写「可设置为公开使用，进群上限 500 个」，但 FAQ 页仍写「暂不支持公开使用」——能力在灰度放量，能不能开取决于账号是否被灰度到；
  - 企业认证：全场景可公开。
- **添加入口**：最新版手机 QQ → `联系人 → 机器人 → 资料页底部「添加到群聊」`。在群设置里找"添加机器人"是另一套入口，看不到自己的机器人。
- **加进群还要改设置**：群设置 → 机器人 → 「可获取的群聊消息范围」设为**全部消息**，否则 @ 了也收不到事件。
- **内部体验号码 20 个**，不受服务范围限制，小范围发码直接用它，不必折腾进群。

> 关键判断：**本方案不需要机器人进群。** 领码走私聊，群只是便利。加群失败不该挡住发码流程。


## 12.7 输入框（已实现）

| 文件 | 作用 |
|---|---|
| `objects/obj_auth_gate/` | 模态窗口：遮罩 + 面板 + `SearchBox` 输入 + 确认按钮（启动时无「关闭」） |
| `objects/obj_auth_gate/Step_1.gml` | **Begin Step：模态输入拦截**，面板外的点击直接抹掉（见下） |
| `objects/obj_auth_gate/Create_0.gml` | 版面尺寸集中定义（`title_y / hint_y / hwid_y / box_y / status_y`），`depth = -15999` |
| `objects/obj_auth_button/` | ~~菜单「授权」胶囊按钮~~ **已停用**（资源保留，不再创建实例） |
| `scripts/auth_client/auth_client.gml` | `auth_clean / auth_verify_code / auth_bind / auth_label` |
| `objects/obj_game_init/Create_0.gml` | 末尾 `auth_init()`（必须在 `native_util` 之后）+ 未授权则弹强制授权窗 |
| `objects/obj_menu_manager/Create_0.gml` | ~~创建入口按钮~~ **已移除创建**：授权窗只在启动未授权时弹一次 |
| `objects/obj_player_menu_btn/Mouse_4.gml` | 首行挡点击：`global.auth_gate_open` 为真时不响应（第二道防线） |
| `objects/obj_startgame_button/Mouse_4.gml` | 同上，挡住「开始游戏」 |
| `objects/obj_world_map_button/Mouse_4.gml` | 同上，挡住世界地图（进关卡的另一个入口） |

实现要点：

- **必须用 `SearchBox`**，别用 `get_string_async`：中文输入法体验差，且 `SearchBox` 已处理粘贴、失焦、闪烁光标。
- `SearchBox` 调 `on_change` 时走 `self.state.on_change(...)`，**`self` 会被绑到 `state` 结构体**，闭包里直接写 `msg = ""` 只会改到结构体上的影子字段。必须 `with (_self_id)` 切回实例。
- 输入框是窗口自己创建的，**不会跟着销毁**，`Destroy_0` 里要显式 `instance_destroy(input_box)`。
- 复制粘贴常带空格/换行/零宽字符，`auth_clean()` 只保留合法字符与连字符，否则玩家会莫名其妙验不过。
- 字形已核对：`font_yuan` / `font_hei` 都覆盖本次全部文案（授权码/绑定/凭证/无效/粘贴/进入游戏…），**不用补字**。
- 坐标走 room 空间。本工程房间 1920×1080 且没改 gui 尺寸，所以 `device_mouse_x_to_gui` 与 room 坐标是同一套；将来若改了 gui 尺寸，两处要一起改。

### 12.7.1 强制授权（启动即弹 · 不给关 · 只授权一次）

`obj_auth_gate` 有**两种模式**，靠 `mandatory` 区分：

| | 普通模式 | 强制模式 |
|---|---|---|
| 触发 | 菜单里点「授权」按钮 | `obj_game_init` 启动时发现未授权 |
| 关闭 | 「稍后再说」/ Esc 都能关 | **没有任何关闭途径** |
| 生命周期 | 随房间销毁 | `persistent = true`，跨房间活到授权成功 |

三个容易踩的点：

1. **`mandatory` 必须用 global 传参，不能在外部赋值**。`instance_create_depth` 之后 Create 是同步执行的，拿到实例再写 `inst.mandatory = true` 已经晚了——按钮坐标、`persistent` 都算完了。做法：创建前置 `global.auth_gate_force = true`，Create 里读它，创建后复位。
2. **`SearchBox` 也要 `persistent`**。窗口跨房间活、输入框不跟着活的话，换房瞬间 `input_box` 变成野指针，一打字就炸。
3. **只挡弹窗本身不够，但也不必逐个改按钮**。弹窗是全屏遮罩，可 GML 的 `Mouse_4` 会发给**所有**实例，遮罩不消费点击。工程里有 76 个对象用 Mouse 事件做按钮、19 个对象在 Step 里轮询 `mouse_check_button_pressed()`，逐个加判断既改不完也必漏。
   正确做法是**在最早的时刻抹掉按键状态**：`Step_1.gml`（Begin Step）判断鼠标是否落在面板矩形内，不在就 `mouse_clear(mb_any)`。事件顺序是 Begin Step → 键盘 → 鼠标事件 → 各对象 Step，所以这一下之后，底层无论用 Mouse 事件还是轮询函数，读到的都是「没按下」。
   三个既有入口（`obj_player_menu_btn` / `obj_startgame_button` / `obj_world_map_button`）上的 `global.auth_gate_open` 判断保留，作为第二道防线。

### 12.7.2 层级与版面（2026-10-29）

**层级**：GML 的 `depth` 合法范围是 `-16000..16000`，`-16000` 就是最顶层（超出会被夹逼）。本对象放 `-15999`，把 `-16000` 留给它创建的 `SearchBox` —— 子实例必须**严格**压在面板之上，否则输入框被面板画没，看起来像「框消失了」。别让两者同层，同层的绘制顺序按实例创建顺序，不可靠。

**版面**：全部纵向位置在 `Create_0` 里一次算好，`Draw_0` 只引用变量，不再出现 `panel_y + 常数`。两处各写一份必然对不齐。当前竖向节奏（相对面板顶部）：标题 50 / 说明 96 / 识别码 128（高 54）/ 输入框 206（高 68）/ 状态 300 / 按钮 = `panel_h - 96`，面板高 430，左右内边距 60。

两个已经修掉的具体缺陷：

| 缺陷 | 原因 | 修法 |
|---|---|---|
| 「本机识别码」标签跑到框外左侧 | 用了 `fa_right` 对齐到 `hwid_x + 22`，右对齐意味着文字往左伸出锚点，5 个字直接顶穿边框 | 改 `fa_left`，识别码本体从 `hwid_x + 22 + hwid_label_w` 开始 |
| 状态行与按钮之间空了 76 px，视觉断层 | 按钮按「面板底部 -102」硬算，状态行却跟着输入框走 | 面板高 480→430，按钮改「面板底部 -96」，两处间距收到 26/34 px |

「只授权一次」不由窗口保证，而是 `auth.dat`：`auth_init()` 恢复成功 → `auth_ok()` 为真 → 根本不会弹窗。换机器/重装系统后 `auth_load()` 判 `machine` 失配，`global.auth_machine_changed = true`，窗口重新变成强制模式，玩家要拿新识别码换码。


## 12.8 风险清单

1. **换密钥 = 所有已发出的码同时失效**，玩家必须重新领。第一次正式发码前就把密钥定死。
2. **池子或账本泄露**：池子给了别人也不够（没有密钥算不出签名）；但池子 + 密钥一起泄露 = 任意造码。两者都已 gitignore。
3. **删 `auth.dat` 可以重输同一个码**。但在**别的机器**上输没用（机器码不匹配），这正是 12.1 的收益。
4. **改计算机名 / 重装系统会让识别码变化**，玩家必须重新领码。这是机器指纹方案的固有代价；`revoke` 只清账本，救不了玩家手上的旧码。
5. **池子会发完**。`pool` 命令看到"剩余 0"就加码；机器人遇到 `PoolExhausted` 会回"暂时发不出码"，不会崩。
6. **DLL 方案与补丁式分发互斥**。将来若改发 `data.win` 补丁，12.4.3 作废。
7. **别宣传"防盗版"**。它是分发控制 + 提高门槛。说成防盗版只会招来"已经被破了"的嘲讽。


## 12.9 部署形态：WebSocket 与 Webhook 二选一（2026-10-29）

### 12.9.1 先把「离线领码」这件事说死

「玩家 @ 机器人要码」这一步**不可能纯离线**，不是实现问题，是架构决定的：

- 算签名必须持有 `SECRET`（`tools/auth_secret.txt`）
- 谁能调起这段签名逻辑，谁就能自己造码
- 所以签名环境必须由作者控制，且必须有东西在玩家请求时运行

QQ 官方机器人的 WebSocket 模式要求一台**常开**的机器（你的电脑）。这是
「不用服务器」这个前提的固有代价：没有服务器，就得有你自己的机器顶上。

### 12.9.2 Webhook 是唯一「不用买服务器也不用开机」的路

QQ 开放平台支持把事件推送方式切换成 **Webhook**：腾讯主动 POST 到你配置的
HTTPS 地址。把那个地址做成**云函数**，就变成「有请求才算、没请求不存在」。

- 没人领码 → 不运行、不花钱、不需要任何机器开着
- 有人领码 → 跑几百毫秒，回码，结束
- 不需要公网 IP、域名、备案、开放入站端口（函数 URL 自带 HTTPS）

代价是**账本必须搬到函数之外**。云函数实例随时被回收，写进本地文件的账本
下一次调用就没了，表现是「每个玩家每次都能领到新码、上限失效」，而且不会
报错——这是这次改动里最容易埋雷的地方。

### 12.9.3 三个必须按官方规则做对的点

| 点 | 规则 | 做错的后果 |
|---|---|---|
| 验签种子 | `seed` = Bot Secret 不足 32 字节就**整体重复**自身，再截断到 32 字节 | 回调地址保存时提示「签名校验不通过」，无其他线索 |
| 签名对象 | `X-Signature-Timestamp` 字符串 + **原始 body 字节** | 同上；中间层改写 body（如反代重新序列化 JSON）也会导致失败 |
| 握手 | 平台保存地址时发 `op=13`，要在 3 秒内回 `{plain_token, signature=Ed25519(seed, event_ts+plain_token)}` | 地址存不进去 |

`seed_from_secret()` 里「整体重复」这点很容易写错成「单字符重复」，两者在
secret 长度不是 32 时结果不同。`scf/ed25519_ref.py` 的 `selftest()` 里专门
测了这条。

### 12.9.4 实现要点

- **零第三方依赖**：不用 `cos-python-sdk-v5`（它依赖 `crcmod`，C 扩展跨平台
  打包容易翻车），COS 签名就是 HMAC-SHA1，用 `hmac` 手写；Ed25519 用纯标准库
  实现，优先走 `cryptography`，没有就用自己的。两个都用 RFC 8032 官方向量自检。
- **性能**：朴素 Ed25519 每做一次点加就求一次模逆，验签要 480 ms，会顶爆 3 秒
  上限。改用**扩展扭曲爱德华兹坐标**把除法推迟到最后一次，降到 3 ms（160 倍）。
- **复用而不复制**：命令解析、文案、发码规则全部 `import bot`，只把账本换成
  COS 版并替换 `bot.issue_for`。复制一份的后果是文案和规则两边漂移。
- **`qq_auth` 只能被加载成一个模块对象**：函数里用 `sys.path` 顺序保证这一点，
  否则 `bot.qq_auth.PoolExhausted` 和 `except` 里的不是同一个类，异常会漏出去
  变成「发码出错了」，而不是「已绑满 2 台」。
- **函数 URL 必须设「免鉴权」**：否则 SCF 自己就把腾讯的请求挡了，返回 401，
  日志里一条业务记录都没有。
- **模块级缓存 token**：暖启动能省一次 HTTPS 往返；冷启动重新取，天经地义。
- **`msg_seq` 用时间戳**：函数每次冷启动 `MSG_SEQ` 字典都是空的，固定 seq 会让
  同一条消息的第二次回复被平台去重丢掉。
- **发码前检查密钥**：`AUTH_SECRET` 还是占位符时，握手照常应答（否则回调地址
  都存不进去，更难查），但领码直接拒绝——那种码游戏端 100% 验不过。

### 12.9.5 成本

云函数每月百万次调用量级的免费额度、COS 存储按 KB 计。几十人的规模，
一年成本在几毛到几块钱量级。

### 12.9.6 文件

| 路径 | 作用 |
|---|---|
| `bots/qq_auth_bot/scf/main.py` | SCF 入口，还原原始 body 后交给 webhook |
| `bots/qq_auth_bot/scf/webhook.py` | 验签、握手、事件分发、发消息 |
| `bots/qq_auth_bot/scf/ed25519_ref.py` | 纯标准库 Ed25519 + RFC 8032 自检 |
| `bots/qq_auth_bot/scf/store.py` | COS 账本 + 手写 COS 签名 |
| `bots/qq_auth_bot/scf/build.py` | 打 zip（剔除密钥，密钥走环境变量） |
| `bots/qq_auth_bot/scf/selftest.py` | 端到端自检，模拟腾讯真实签名请求 |
| `bots/qq_auth_bot/scf/README.md` | 部署步骤与排错表 |

### 12.9.7 两条路不能同时开

Webhook 和 WebSocket 同时启用时，同一条消息会被处理两次：玩家收到两条回复，
账本写两遍（第二次命中已有 hwid，返回同一个码，所以不至于错乱，但很脏）。
切换后本地不要再跑 `start_bot.bat`。
