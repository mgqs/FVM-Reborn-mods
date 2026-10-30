/* ============================================================================
 * B 页面（耐张段台账 - 导线截面）· 正式版
 *
 * 已验证通过：localStorage=object，从 A 页面读到了型号（如 JKLJY-800）。
 *
 * 相比你的原代码，改动两处：
 *   ① 取型号：从 localStorage 读，不再调 get('档距段台账')（B 页面看不见这个节点）
 *   ② 判断顺序：型号为空时静默跳过，不误报"不匹配"
 *   ③ 顺手加了一层保护：tyTipyShow 对象还没创建时调用 .hide() 不会抛异常
 *
 * insertRecord / insertExternalRuleResult / getTime 原样保留，一个字没改。
 * ========================================================================= */

var XH_DEBUG = false;   /* 调试开关，已关闭 */


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


/* ============================ 取型号（来自 A 页面） ============================ */

let typeNumber = '';
try {
    if (window.localStorage) {
        const xhRaw = window.localStorage.getItem('XH_DJDT_TYPE');
        if (xhRaw !== null && xhRaw !== '') {
            typeNumber = String(xhRaw);
        }
    }
} catch (e) { }

//导线截面
let thisElementValue = this.element.value;


/* ============================ 判断逻辑 ============================ */

//判断型号包含导线截面吗
if (typeNumber && typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
    const xhTipOk = window[this.stepId + 'tyTipyShow'];
    if (xhTipOk && xhTipOk.hide) xhTipOk.hide();

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
   这样"A 页面还没填就打开 B"不会误报，等 A 填完再回到 B 就自动恢复校验。 */
