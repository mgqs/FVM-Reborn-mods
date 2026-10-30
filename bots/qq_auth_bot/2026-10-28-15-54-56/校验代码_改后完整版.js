/* ============================================================================
 * 你的代码 · 修改后完整版 v3（直接整段替换你现在的代码页）
 *
 * v3：存储介质可切（sessionStorage / localStorage），默认 session ——
 *     生命周期天然绑定这次标签页会话，关掉浏览器自动清空，不用再操心 TTL。
 * v2：修正「值改变后缓存不同步」：写入改成按行覆盖，不再只增不减；带 scope 隔离。
 * v1：首次给出跨页面缓存方案。
 *
 * 相比你原代码，仍然是那 3 处结构变化（见文件内 ★标记）。
 * ========================================================================= */


/* ========================= 你原有的工具函数（未改） ========================= */

const insertRecord = ({ inputContent, prompt, forceSave, triggerStatus, codeCtx, time }) => {
    bootStrap.invoke('insertRecord', {
        inputContent: inputContent,
        prompt: prompt,

        forceSave: forceSave,
        triggerStatus: triggerStatus,//和prompt强相反

        elementId: codeCtx.elementId,
        elementName: codeCtx.elementName,
        stepId: codeCtx.stepid,
        stepName: codeCtx.stepName,
        nodeId: codeCtx.nodeId,
        nodeName: codeCtx.nodeName,

        operatorTime: getTime(time)
    });
}

const insertExternalRuleResult = ({ inputContent, prompt, triggerStatus, codeCtx, time }) => {
    bootStrap.invoke('insertExternalRuleResult', {
        ruleId: codeCtx.ruleId,
        inputContent: inputContent,
        prompt: prompt,
        triggerStatus: triggerStatus,
        operatorTime: getTime(time),
        stepId: codeCtx.stepid,
        stepName: codeCtx.stepName,
        nodeId: codeCtx.nodeId,
        nodeName: codeCtx.nodeName,
        elementId: codeCtx.elementId,
        elementName: codeCtx.elementName
    });
}

function getTime(date) {
    if (date == null || date == undefined) {
        return date;
    }
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    const formattedTime = year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
    return formattedTime;
}


/* =================== ★改动1：跨页面缓存（值一改就覆盖同步） =================== */

const XH_KEY = 'XH_DJDT_TYPE_CACHE';       // 缓存键
const XH_TTL = 24 * 60 * 60 * 1000;        // 只做极端兜底，正常靠"每次重写"保证新鲜

/* 存储介质：
 *   'session' → sessionStorage：生命周期天然绑定这次标签页会话，
 *               关掉浏览器自动清空，不用管 TTL、不用手动清理。
 *               ⚠️ 只保证"同一个标签页内"能共享（A 关闭后在同标签页打开 B 可以）。
 *   'local'   → localStorage：跨标签页、关浏览器也留。A / B 在不同标签页打开时用这个。
 */
const XH_STORAGE = 'session';
const XH_NODE_A = '档距段台账';             // A 页面节点名
const XH_NODE_B = '耐张段台账';             // B 页面节点名
const XH_ELE_A = '型号';                    // A 页面元素名
const XH_ELE_B = '导线截面';                // B 页面元素名

// 业务隔离维度：换工程/换线路时不会串数据。⚠️ 换成你表单里真实的节点名+元素名
const XH_SCOPE_FIELDS = [
    ['工程信息', '工程编号'],
    ['工程信息', '线路名称'],
    ['基本信息', '线路名称']
];

// 当前所在位置（你原来 codeCtx 里就在用 elementName / nodeName）
const xhNodeName = this.nodeName || '';
const xhEleName = this.elementName || '';
const xhInA = xhNodeName.indexOf(XH_NODE_A) !== -1;

// 存储介质访问层（session / local 一行切换）
function xhStore() {
    try {
        return XH_STORAGE === 'local' ? window.localStorage : window.sessionStorage;
    } catch (e) {
        return null;
    }
}

function xhReadCache() {
    try {
        const st = xhStore();
        const raw = st ? st.getItem(XH_KEY) : null;
        const o = raw ? JSON.parse(raw) : null;
        if (o && typeof o === 'object') {
            if (!Array.isArray(o.list)) o.list = [];
            if (!o.rows || typeof o.rows !== 'object') o.rows = {};
            return o;
        }
    } catch (e) { }
    return { list: [], rows: {}, t: 0, scope: '' };
}

function xhWriteCache(obj) {
    try {
        const st = xhStore();
        if (st) st.setItem(XH_KEY, JSON.stringify(obj));
    } catch (e) { }
}

function xhClearCache() {
    try {
        const st = xhStore();
        if (st) st.removeItem(XH_KEY);
    } catch (e) { }
}

// 按"节点名 + 元素名"取当前表单里的值（A 页面还开着时有效）
function xhGetNodeValue(nodeName, elementName) {
    try {
        const node = bootStrap.invoke('getNodeMap').get(nodeName);
        const ele = node && node.get(elementName);
        return ele ? ele.value : undefined;
    } catch (e) {
        return undefined;
    }
}

// 取业务隔离标识（A / B 两边算法必须完全一致）
function xhGetScope() {
    for (let i = 0; i < XH_SCOPE_FIELDS.length; i++) {
        const v = xhGetNodeValue(XH_SCOPE_FIELDS[i][0], XH_SCOPE_FIELDS[i][1]);
        if (v !== undefined && v !== null && String(v).trim() !== '') return String(v).trim();
    }
    return '';
}

// 取当前行的唯一标识，用于"改值覆盖"而不是"再追加一条"
function xhGetRowKey(ctx) {
    const keys = ['rowId', 'rowKey', 'dataIndex', 'rowIndex', 'index'];
    for (let i = 0; i < keys.length; i++) {
        const v = ctx[keys[i]];
        if (v !== undefined && v !== null && v !== '') return String(v);
    }
    const el = ctx.element || {};
    for (let i = 0; i < keys.length; i++) {
        const v = el[keys[i]];
        if (v !== undefined && v !== null && v !== '') return String(v);
    }
    return '';
}

// A 页面执行时：把「型号」写进缓存 —— 覆盖式，值一改立刻同步
if (xhInA) {
    let xhModelA = xhGetNodeValue(XH_NODE_A, XH_ELE_A);
    if (xhModelA === undefined || xhModelA === null || String(xhModelA).trim() === '') {
        xhModelA = (this.element && this.element.value) || '';
    }
    xhModelA = String(xhModelA == null ? '' : xhModelA).trim();

    const xhScope = xhGetScope();
    const xhCache = xhReadCache();

    // 换了工程 → 旧缓存整体作废，避免读到上个工程的型号
    if (xhCache.scope !== xhScope) {
        xhCache.rows = {};
        xhCache.list = [];
        xhCache.scope = xhScope;
    }

    if (xhModelA) {
        const xhRowKey = xhGetRowKey(this);
        if (xhRowKey) {
            // 有行标识：同一行反复改 → 覆盖这一个 key，不会留下历史值
            xhCache.rows[xhRowKey] = xhModelA;
            xhCache.list = Object.keys(xhCache.rows)
                .map(k => xhCache.rows[k])
                .filter(v => v);
        } else {
            // 没有行标识（单值字段 / 引擎不提供 rowIndex）→ 直接整体覆盖
            xhCache.rows = {};
            xhCache.list = [xhModelA];
        }
        xhCache.t = Date.now();
        xhWriteCache(xhCache);
    }
}


/* ========================= ★改动3：原校验逻辑（包一层） ========================= */
/* 包 if (!xhInA) 是为了让这段代码在 A 页面执行时跳过，
   否则在 A 页面也会跑"导线截面比对"，弹出莫名其妙的提示。       */

if (!xhInA) {

    // 获取型号
    //let typeNumber = bootStrap.invoke('getNodeMap').get('耐张段台账').get('型号').value;
    //导线截面

    // ★改动2：原来是下面这一行，A 页面关闭后取不到值还会抛异常
    //let typeNumber = bootStrap.invoke('getNodeMap').get('档距段台账').get('型号').value;

    let typeNumber = '';
    const xhCache = xhReadCache();
    const xhScopeNow = xhGetScope();
    const xhScopeOk = (xhCache.scope || '') === xhScopeNow;      // 必须同一个工程
    const xhValid = xhScopeOk
        && xhCache.list.length > 0
        && (Date.now() - (xhCache.t || 0) < XH_TTL);

    if (xhValid) {
        // 用 A 页面（已关闭）留下的缓存；多个档距段型号用逗号拼起来
        typeNumber = xhCache.list.join(',');
    } else {
        // 兜底：A 页面此刻还开着，直接读节点（加了空值保护，不会再抛异常）
        const xhDirect = xhGetNodeValue(XH_NODE_A, XH_ELE_A);
        typeNumber = (xhDirect === undefined || xhDirect === null) ? '' : String(xhDirect);
    }

    let thisElementValue = this.element.value;
    //判断型号包含导线截面吗
    if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
        window[this.stepId + 'tyTipyShow'].hide();
        insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });
    } else {
        let massage = '导线截面需要和型号匹配';
        window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage);
        insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
    }
}


/* ============================================================================
 * 补充：台账「删行」怎么办？
 *   元素级事件只能覆盖"改值"，覆盖不了"删行"—— 删掉的那行不会触发型号的
 *   值改变事件，缓存里就会残留一个已删除的型号，B 页面还能匹配上。
 *
 *   如果你的档距段台账会增删行，建议在 A 页面「保存」时全量重建一次缓存：
 *
 *   const xhScope = xhGetScope();
 *   const node = bootStrap.invoke('getNodeMap').get(XH_NODE_A);
 *   // ↓ API 名按你们引擎实际情况改（getRows / rows / getData 都可能）
 *   const rows = typeof node.getRows === 'function' ? node.getRows() : (node.rows || []);
 *   const list = [];
 *   (rows || []).forEach(function (r) {
 *       const v = r && (r['型号'] || (r.get && r.get('型号') && r.get('型号').value));
 *       const s = String(v == null ? '' : v).trim();
 *       if (s && list.indexOf(s) === -1) list.push(s);
 *   });
 *   xhWriteCache({ list: list, rows: {}, t: Date.now(), scope: xhScope });
 *
 * ---- 换工程时清掉（两种介质都清，稳妥）：
 *   xhClearCache();
 *   try { window.localStorage.removeItem(XH_KEY); window.sessionStorage.removeItem(XH_KEY); } catch (e) {}
 * ========================================================================= */


/* ============================================================================
 * 附：只想要"最小最小"的改法（3 行版，不换存储结构）
 *
 * 如果你不想动上面的结构，就在 A 页面把原来那行读完顺手存一下：
 *
 *   let typeNumber = bootStrap.invoke('getNodeMap').get('档距段台账').get('型号').value;
 *   if (typeNumber) { sessionStorage.setItem('XH_DJDT_TYPE', String(typeNumber)); }
 *
 * B 页面：
 *
 *   let typeNumber = sessionStorage.getItem('XH_DJDT_TYPE') || '';
 *   if (!typeNumber) {
 *       typeNumber = bootStrap.invoke('getNodeMap').get('档距段台账').get('型号').value || '';
 *   }
 *
 * 区别（很重要）：
 *   · 这 3 行只有"真的执行到这段代码"时才写缓存。如果用户填完型号没触发校验
 *     （比如直接点关闭），缓存里就没值，B 页面照样取不到。
 *   · 上面的完整版挂在元素的值改变事件上，填一次写一次，更保险。
 *   · 而且它不区分工程、不处理改值/删行，属于能跑但不严谨的版本。
 * ========================================================================= */
