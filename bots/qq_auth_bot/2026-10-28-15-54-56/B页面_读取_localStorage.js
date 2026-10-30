/* ============================================================================
 * B 页面（耐张段台账 - 导线截面）· 从 localStorage 读取 A 存下的型号
 *
 * 相比你的原代码，只有两处改动：
 *   ① 取型号：不再调 get('档距段台账')（B 页面根本看不见这个节点，必然 undefined），
 *             改成从 localStorage 读
 *   ② 判断顺序：型号为空时不弹"不匹配"，静默跳过，避免误报
 *
 * insertRecord / insertExternalRuleResult / getTime 原样保留，一个字没改。
 *
 * XH_DEBUG = true 时不跑校验，只把读取结果用报错抛出来，方便在"只显示报错"的
 * 控制台里确认。调通后改成 false。
 * ========================================================================= */

var XH_DEBUG = true;   /* ★ 调通后改成 false */


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


/* ============================ 取型号 ============================ */

let typeNumber = '';
let xhEnv = '';
let xhErr = '';

try {
    xhEnv = typeof window.localStorage;                 /* "object" = 可用，"undefined" = 环境不支持 */
    if (window.localStorage) {
        const xhRaw = window.localStorage.getItem('XH_DJDT_TYPE');
        if (xhRaw !== null && xhRaw !== '') {
            typeNumber = String(xhRaw);
        }
    }
} catch (e) {
    xhErr = (e && e.message) || String(e);
}

let thisElementValue = this.element.value;              /* 本元素（导线截面）的值 */

/* 调试档：不跑校验，直接把读取结果抛出来 */
if (XH_DEBUG) {
    throw new Error(
        '[XH] 型号=' + (typeNumber || '(空)') +
        ' | localStorage=' + xhEnv +
        ' | 导线截面=' + thisElementValue +
        (xhErr ? ' | 异常=' + xhErr : '')
    );
}


/* ==================== 原来的判断逻辑（只调整了顺序） ==================== */

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
/* typeNumber 为空 → 两个分支都不进：拿不到 A 的型号就不校验、不弹提示、不记结果。
   注意这里没有再用 getNodeMap 兜底 —— B 页面里 get('档距段台账') 永远是 undefined，
   加了也只会白白抛异常。 */
