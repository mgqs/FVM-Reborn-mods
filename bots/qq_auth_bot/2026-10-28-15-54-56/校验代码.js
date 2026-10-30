/* ============================================================================
 * 你的校验代码 · v3（读取不再抛异常 + 写入失败会打日志）
 *
 * v3 解决的问题：
 *   上次报 <anonymous>:86:86 "reading 'get'"，是 `||` 右边的兜底语句炸的 ——
 *   存储里没值 → 落到 getNodeMap → get('档距段台账') 是 undefined → .get('型号') 抛错。
 *   根因是 A 页面的写入没成功，但被 catch(e){} 静默吞了，看不到线索。
 *
 * v3 三件事：
 *   ① 取节点值统一走 xhNodeValue()，任何一层缺失都返回 ''，绝不抛异常
 *   ② 写入成功 / 失败都打一行控制台日志（[XH] 开头），调通后可以删
 *   ③ 取不到 A 数据时给一句明确提示，不再误报"导线截面需要和型号匹配"
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


/* ================== ★新增：三个小工具函数（都不会抛异常） ================== */

/* 存：window 全局变量优先（你原来 tyTipyShow 就是这么存活的），再尝试两种 storage */
function xhSet(key, value) {
    try { window[key] = value; } catch (e) { }
    try { if (window.localStorage) window.localStorage.setItem(key, value); } catch (e) { }
    try { if (window.sessionStorage) window.sessionStorage.setItem(key, value); } catch (e) { }
}

/* 取：三级降级，取不到返回 '' */
function xhGet(key) {
    try {
        const v = window[key];
        if (v !== undefined && v !== null && v !== '') return String(v);
    } catch (e) { }
    try {
        if (window.localStorage) {
            const v = window.localStorage.getItem(key);
            if (v !== null && v !== '') return String(v);
        }
    } catch (e) { }
    try {
        if (window.sessionStorage) {
            const v = window.sessionStorage.getItem(key);
            if (v !== null && v !== '') return String(v);
        }
    } catch (e) { }
    return '';
}

/* 按"节点名 + 元素名"取值，节点或元素不存在时返回 ''（关键：不再抛异常） */
function xhNodeValue(nodeName, elementName) {
    try {
        const nm = bootStrap.invoke('getNodeMap');
        if (!nm) return '';
        const node = nm.get(nodeName);
        if (!node) return '';
        const ele = node.get(elementName);
        if (!ele) return '';
        return ele.value == null ? '' : String(ele.value);
    } catch (e) {
        return '';
    }
}


/* ================== ★A 页面：把型号存一份（带日志） ================== */
/* 这段在 A、B 页面都会执行：
   · A 页面打开时 → 取得到值 → 存起来，并打印 [XH] 已存型号
   · A 已关闭（在 B 页面执行） → 取到 ''，什么都不做，也不会报错     */

try {
    let _xh = xhNodeValue('档距段台账', '型号');
    if (!_xh && this.elementName === '型号' && this.element) {
        _xh = this.element.value || '';
    }
    if (_xh) {
        xhSet('XH_DJDT_TYPE', String(_xh));
        console.log('[XH] 已存型号：', String(_xh));
    }
} catch (e) {
    console.warn('[XH] 存型号失败：', e && e.message);
}


// 获取型号
//let typeNumber = bootStrap.invoke('getNodeMap').get('耐张段台账').get('型号').value;
//导线截面

// ★读取：先取存下来的，取不到再走 getNodeMap（这一步已包在 xhNodeValue 里，不会抛错）
let typeNumber = xhGet('XH_DJDT_TYPE') || xhNodeValue('档距段台账', '型号');

let thisElementValue = this.element.value;

// ★新增分支：A 的数据压根没取到 —— 单独提示，不要和"不匹配"混在一起
if (!typeNumber) {
    let massage = '未获取到【档距段台账-型号】，请先填写档距段台账，再录入导线截面';
    window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage);
    insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
    insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
}
//判断型号包含导线截面吗
else if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
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


/* ============================================================================
 * 如果 B 页面弹出"未获取到【档距段台账-型号】"，说明 A 那边没存进去。
 * 在 A 页面按 F12，控制台执行下面这段，看真实的节点名和元素名：
 *
 *   const nm = bootStrap.invoke('getNodeMap');
 *   console.log('节点列表：', nm instanceof Map ? Array.from(nm.keys()) : Object.keys(nm));
 *   const n = nm.get('档距段台账');
 *   console.log('档距段台账存在？', !!n, n && (n instanceof Map ? Array.from(n.keys()) : Object.keys(n)));
 *
 * 把打印出来的名字替换掉代码里的 '档距段台账' / '型号' 即可。
 * 这一步不能省 —— 之前写入失败被 catch 吞了，就是节点名/元素名对不上导致的。
 * ========================================================================= */
