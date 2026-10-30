/* ============================================================================
 * B 页面（耐张段台账 - 导线截面）· 读取 A 存的值 + 分段校验
 *
 * 相比你的原代码，改动只有两处：
 *   ① 「取型号」那一段：不再调 get('档距段台账')，改成四层查找（与 A 侧写入的四层对应）
 *   ② 判断顺序：typeNumber 为空时不再弹"不匹配"，改为静默跳过（避免误报）
 *
 * insertRecord / insertExternalRuleResult / getTime 原样保留，一个字没改。
 *
 * XH_DEBUG = true 时不会执行校验，而是把"读到什么、从哪层读到的、各层是否可用"
 * 用报错抛出来 —— 这样在 A 页面不用验证，光看 B 页面的报错就能判断 A 到底写没写成。
 * 调通后把它改成 false 即可。
 * ========================================================================= */

var XH_DEBUG = true;   /* ★ 调通后改成 false */

/* ---------- 四层查找：与 A 页面写入的四层一一对应 ---------- */
function xhLookup() {
    var r = { v: '', from: '无', diag: {} };

    /* 1. sessionStorage（同标签页刷新后仍在） */
    try {
        r.diag.sessionStorage = typeof window.sessionStorage;
        if (window.sessionStorage) {
            var a = window.sessionStorage.getItem('XH_DJDT_TYPE');
            if (a !== null && a !== '') { r.v = String(a); r.from = 'sessionStorage'; return r; }
        }
    } catch (e) { r.diag.sessionStorage = 'ERR'; }

    /* 2. window.top（父窗口，切换步骤时通常存活） */
    try {
        r.diag.top = (window === window.top) ? '同一窗口' : '不同窗口';
        if (window.top && window.top.XH_DJDT_TYPE) {
            r.v = String(window.top.XH_DJDT_TYPE); r.from = 'window.top'; return r;
        }
    } catch (e) { r.diag.top = 'ERR'; }

    /* 3. 当前 window */
    try {
        if (window.XH_DJDT_TYPE) { r.v = String(window.XH_DJDT_TYPE); r.from = 'window'; return r; }
    } catch (e) { }

    /* 4. localStorage */
    try {
        r.diag.localStorage = typeof window.localStorage;
        if (window.localStorage) {
            var b = window.localStorage.getItem('XH_DJDT_TYPE');
            if (b !== null && b !== '') { r.v = String(b); r.from = 'localStorage'; return r; }
        }
    } catch (e) { r.diag.localStorage = 'ERR'; }

    return r;
}


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


/* ============================ 取值 ============================ */

let xhRes = xhLookup();
let typeNumber = xhRes.v;                                   // A 页面存过来的型号
let thisElementValue = this.element.value;                  // 本元素（导线截面）的值

/* 调试档：不跑校验，直接把结果抛出来，方便在"只显示报错"的控制台里看 */
if (XH_DEBUG) {
    throw new Error(
        '[XH] 读到的型号=' + (typeNumber || '(空)') +
        ' | 取自=' + xhRes.from +
        ' | 导线截面=' + thisElementValue +
        ' | 环境=' + JSON.stringify(xhRes.diag)
    );
}


/* ==================== 原来的判断逻辑（只调整顺序） ==================== */

//判断型号包含导线截面吗
if (typeNumber && typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
    window[this.stepId + 'tyTipyShow'].hide();
    insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
    //保存时强制校验
    insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });
} else if (typeNumber) {
    let massage = '导线截面需要和型号匹配';
    window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage);
    insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
    //保存时强制校验
    insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
}
/* typeNumber 为空 → 两个分支都不进：拿不到参照值就不校验、不弹提示、不记结果，
   避免在取值通道没打通之前一直误报"导线截面需要和型号匹配"。 */
