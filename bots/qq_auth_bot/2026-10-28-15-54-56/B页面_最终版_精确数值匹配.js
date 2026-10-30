/* ============================================================================
 * B 页面（耐张段台账 - 导线截面）· 精确数值比对版
 *
 * 改了什么：判断条件从「型号字符串包含导线截面」换成「两边数字完全相等」。
 *
 *   原写法：typeNumber.includes(thisElementValue)
 *     型号 JKLJY-800 时，填 8 → true（错误通过）
 *                     填 80 → true（错误通过）
 *                     填 800 → true（正确）
 *   新写法：从型号里取出第一段数字作为应填值，再和导线截面的数字严格比较
 *     型号 JKLJY-800    → 应填 800，填 8 / 80 / 8000 都不通过 ✓
 *     型号 LGJ-240/30   → 应填 240（/30 是钢芯截面，不参与比对）
 *     型号 JLKLY-150/20 → 应填 150
 *
 * 其余一律保持原样：insertRecord / insertExternalRuleResult / getTime 未改，
 * 两次调用的参数、执行顺序、提示文案都没动。
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
           let massage = '导线截面应为 ' + xhExpect + '，与型号 ' + typeNumber + ' 不匹配';
           这里保留你原来的文案没动。 */
        let massage = '导线截面需要和型号匹配';

        try { window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage); } catch (e) { }

        insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });

    }
}
/* 拿不到型号（A 页面还没填 / 缓存为空）→ 整体跳过，不校验、不提示、不记结果 */
