/* ============================================================================
 * 调试版 v4 —— 所有提示改为 console.log，不调用 tyTipyShow / insertRecord
 *
 * 为什么改：
 *   上次报 <anonymous>:147:50 "Fucntion tyTipyShow is not registered"
 *   → 这段代码在 A 页面也执行了，而 A 页面的步骤里没注册这个提示规则。
 *   调试阶段先把所有 UI 调用停掉，只看控制台，界面就不会再报错。
 *
 * 调通之后：把标了「调通后打开」的几段注释解开，恢复原来的提示逻辑。
 *
 * 控制台会打印这些（都以前缀 [XH] 开头，方便过滤）：
 *   1) 当前上下文：stepId / nodeName / elementName / elementId
 *   2) 当前节点列表 + 档距段台账里的元素列表   ← 用来确认真实名字
 *   3) 缓存里的型号 / getNodeMap 读到的型号 / 最终用的 typeNumber
 *   4) 比对结果
 * ========================================================================= */


/* ========================= 你原有的工具函数（保留，暂不调用） ========================= */

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


/* ================== 三个工具函数（都不会抛异常） ================== */

function xhSet(key, value) {
    try { window[key] = value; } catch (e) { }
    try { if (window.localStorage) window.localStorage.setItem(key, value); } catch (e) { }
    try { if (window.sessionStorage) window.sessionStorage.setItem(key, value); } catch (e) { }
}

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

function xhKeys(obj) {
    try {
        if (!obj) return [];
        if (obj instanceof Map) return Array.from(obj.keys());
        if (typeof obj.keys === 'function') return Array.from(obj.keys());
        return Object.keys(obj);
    } catch (e) {
        return [];
    }
}


/* ================== ① 先打印当前上下文和真实名字（最重要） ================== */

console.log('[XH] ===== 校验触发 =====');
console.log('[XH] stepId=%s | nodeName=%s | elementName=%s | elementId=%s',
    this.stepId, this.nodeName, this.elementName, this.elementId);

try {
    const nm = bootStrap.invoke('getNodeMap');
    console.log('[XH] 节点列表 =', xhKeys(nm));

    const nodeA = nm && nm.get('档距段台账');
    console.log('[XH] 档距段台账 存在？', !!nodeA, '元素列表 =', xhKeys(nodeA));

    const nodeB = nm && nm.get('耐张段台账');
    console.log('[XH] 耐张段台账 存在？', !!nodeB, '元素列表 =', xhKeys(nodeB));
} catch (e) {
    console.warn('[XH] 打印节点信息失败：', e && e.message);
}


/* ================== ② A 页面：把型号存一份 ================== */

try {
    let _xh = xhNodeValue('档距段台账', '型号');
    if (!_xh && this.elementName === '型号' && this.element) {
        _xh = this.element.value || '';
    }
    if (_xh) {
        xhSet('XH_DJDT_TYPE', String(_xh));
        console.log('[XH] 已存型号 =', String(_xh));
    } else {
        console.log('[XH] 本次没取到型号，未写入缓存');
    }
} catch (e) {
    console.warn('[XH] 存型号失败：', e && e.message);
}


/* ================== ③ 读取 + 比对，结果只打印，不弹提示 ================== */

// 获取型号
//let typeNumber = bootStrap.invoke('getNodeMap').get('耐张段台账').get('型号').value;
//导线截面

const xhCached = xhGet('XH_DJDT_TYPE');
const xhDirect = xhNodeValue('档距段台账', '型号');
let typeNumber = xhCached || xhDirect;

let thisElementValue = this.element.value;

const xhMatched = typeNumber.includes(thisElementValue) && thisElementValue.length > 0;

console.log('[XH] 缓存里的型号 =', JSON.stringify(xhCached));
console.log('[XH] getNodeMap 读到的型号 =', JSON.stringify(xhDirect));
console.log('[XH] 最终 typeNumber =', JSON.stringify(typeNumber));
console.log('[XH] 当前元素值 thisElementValue =', JSON.stringify(thisElementValue));
console.log('[XH] 比对结果 =', xhMatched ? '通过' : '不匹配');


/* ================== ④ 原来的提示逻辑（先注释掉，调通后打开） ================== */

// if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
//     window[this.stepId + 'tyTipyShow'].hide();
//     insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
//     insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });
// } else {
//     let massage = '导线截面需要和型号匹配';
//     window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage);
//     insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
//     insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
// }


/* ============================================================================
 * 用法
 *
 * 1) 打开 A 页面，填型号，让它失焦触发校验
 *    → 控制台应出现：
 *        [XH] 节点列表 = ["...", "..."]              ← 把这一行发我
 *        [XH] 档距段台账 存在？ true 元素列表 = [...]  ← 和这一行
 *        [XH] 已存型号 = "LGJ-240/30"
 *
 * 2) 关闭 A，打开 B，填导线截面
 *    → 控制台应出现：
 *        [XH] 缓存里的型号 = "LGJ-240/30"
 *        [XH] 最终 typeNumber = "LGJ-240/30"
 *        [XH] 比对结果 = 通过 / 不匹配
 *
 * 3) 只要第 1 步的「已存型号」和第 2 步的「缓存里的型号」对得上，
 *    逻辑就通了。此时把 ④ 那段注释解开，恢复原来的提示即可。
 *
 * 注意：tyTipyShow 在有些步骤里没注册，所以恢复提示时建议包一层：
 *   try { window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage); }
 *   catch (e) { console.warn('[XH] tyTipyShow 不可用：', massage); }
 * ========================================================================= */
