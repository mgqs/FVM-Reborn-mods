/* ============================================================================
 * B 页面（耐张段台账 - 导线截面）· 精确数值比对 + stepId 修正
 *
 * 本次修正：`Error: 插入数据失败，未携带 stepId`
 *   你原来的工具函数里写的是 `stepId: codeCtx.stepid`（小写 d），
 *   但这个上下文对象的真实字段是 `stepId`（大写 I）—— 所以传进去是 undefined，
 *   平台校验不通过，insertRecord 直接抛异常。
 *   改法：`stepId: codeCtx.stepId || codeCtx.stepid`，两种拼写都兼容。
 *
 * 顺带说明：这条报错出现，说明**数值比对已经通过了**（走到了"通过"分支才会调
 * insertRecord）。也就是说 A→B 取值、800 精确匹配这两步都是对的。
 *
 * 其余逻辑不变：
 *   · 型号取第一段数字，导线截面必须数值完全相等
 *   · insertRecord / insertExternalRuleResult / getTime 的其他字段、参数、顺序原样
 * ========================================================================= */


/* ========================= 工具函数（只修了 stepId 拼写） ========================= */

const insertRecord = ({ inputContent, prompt, forceSave, triggerStatus, codeCtx, time }) => {
    bootStrap.invoke('insertRecord', {
        inputContent: inputContent,
        prompt: prompt,

        forceSave: forceSave,
        triggerStatus: triggerStatus,//和prompt强相反

        elementId: codeCtx.elementId,
        elementName: codeCtx.elementName,
        stepId: codeCtx.stepId || codeCtx.stepid,          /* ★ 修正：原来只有 codeCtx.stepid */
        stepName: codeCtx.stepName,
        nodeId: codeCtx.nodeId,
        nodeName: codeCtx.nodeName,

        operatorTime: getTime(time)
    });
}

const insertExternalRuleResult = ({ inputContent, prompt, triggerStatus, codeCtx, time }) => {
    bootStrap.invoke('insertExternalRuleResult', {
        ruleId: codeCtx.ruleId || codeCtx.ruleid,          /* ★ 同样加一层兼容 */
        inputContent: inputContent,
        prompt: prompt,
        triggerStatus: triggerStatus,
        operatorTime: getTime(time),
        stepId: codeCtx.stepId || codeCtx.stepid,          /* ★ 修正 */
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


/* ================== 取值：A 页面存下的型号 ================== */

// 获取型号
//let typeNumber = bootStrap.invoke('getNodeMap').get('档距段台账').get('型号').value;

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


/* ================== 数字提取：取第一段数字 ================== */

/* JKLJY-800 → 800   LGJ-240/30 → 240   JLKLY-150/20 → 150   乱填的文字 → null */
function xhFirstNumber(s) {
    const m = String(s === null || s === undefined ? '' : s).match(/\d+(?:\.\d+)?/);
    if (!m) return null;
    const n = Number(m[0]);
    return isNaN(n) ? null : n;
}


/* ================== 判断 ================== */

if (typeNumber) {

    const xhExpect = xhFirstNumber(typeNumber);          // 型号里的截面积，如 800
    const xhActual = xhFirstNumber(thisElementValue);    // 导线截面里填的数字，如 800

    /* 必须两边都取到数字，且数值完全相等，才算通过 */
    if (xhExpect !== null && xhActual !== null && xhExpect === xhActual) {

        try { window[this.stepId + 'tyTipyShow'].hide(); } catch (e) { }

        insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });

    } else {

        /* 想让提示带上具体应填值，把下面这句换成：
           let massage = '导线截面应为 ' + xhExpect + '，与型号 ' + typeNumber + ' 不匹配';  */
        let massage = '导线截面需要和型号匹配';

        try { window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage); } catch (e) { }

        insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });

    }
}
/* 拿不到型号（A 页面还没填 / 缓存为空）→ 整体跳过，不校验、不提示、不记结果 */
