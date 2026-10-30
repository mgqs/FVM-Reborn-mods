/* ============================================================================
 * B 页面（耐张段台账 - 导线截面）· 正式版 v2
 *
 * v2 修正了什么：
 *   上一版报 `Fuction tyTipyShow is not registered` —— 这个代码页没有注册
 *   tyTipyShow 这个函数，所以 bootStrap.invoke('tyTipyShow', ...) 直接抛异常。
 *   而这一行写在 insertRecord / insertExternalRuleResult 前面，一抛错，
 *   后面两条校验记录全部没执行，等于"校验结果丢了"。
 *
 *   三个处理：
 *     ① 提示函数调用全部包进 try/catch，抛错也不影响后面的记录写入
 *     ② 顺序反过来：先写 insertRecord / insertExternalRuleResult，再尝试弹提示
 *     ③ 提示函数名不再写死，按候选名单逐个试（tyTipyShow / tyTipShow / tipShow ...）
 *        哪个能注册就用哪个，全都不行就不弹，但校验结果照常记录
 *
 * 取型号：仍从 localStorage 读 A 页面存下的值（已验证可用）。
 * insertRecord / insertExternalRuleResult / getTime 原样保留。
 * ========================================================================= */

var XH_DEBUG = false;


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


/* ==================== 提示：按候选名逐个试，失败一律不抛 ==================== */

function xhShowTip(ctx, msg) {
    const names = ['tyTipyShow', 'tyTipShow', 'tipShow', 'showTip', 'showMessage', 'tip'];
    for (let i = 0; i < names.length; i++) {
        try {
            const r = bootStrap.invoke(names[i], ctx, msg);
            if (r) {
                try { window[ctx.stepId + 'tyTipyShow'] = r; } catch (e) { }
                return r;
            }
        } catch (e) { }
    }
    return null;
}

function xhHideTip(ctx) {
    try {
        const o = window[ctx.stepId + 'tyTipyShow'];
        if (o && typeof o.hide === 'function') o.hide();
    } catch (e) { }
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


/* ============================ 判断 + 记录 ============================ */

//判断型号包含导线截面吗
if (typeNumber && typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {

    /* 先记结果：这两条是最关键的，不能被提示函数拖死 */
    insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
    //保存时强制校验
    insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });

    /* 再收提示：失败就算了，不影响上面两条 */
    xhHideTip(this);

} else if (typeNumber) {

    let massage = '导线截面需要和型号匹配';

    insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
    //保存时强制校验
    insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });

    xhShowTip(this, massage);
}
/* typeNumber 为空 → 两个分支都不进：拿不到 A 的型号就不校验、不弹提示、不记结果 */
