/* ============================================================================
 * B 页面（耐张段台账 - 导线截面）· 最终版：判断逻辑与你的源代码完全一致
 *
 * 和你源代码相比，只有三处差异，判断逻辑本身一个字没动：
 *   ① 取值来源：getNodeMap 取档距段台账 → localStorage 读 A 存的值
 *   ② 外面包一层 if (typeNumber)：拿不到型号就整体跳过，避免空值误报
 *   ③ 两处提示调用各加一个 try/catch：tyTipyShow 未注册时不会抛异常中断
 *
 * 判断表达式、if/else 结构、四次 insertRecord / insertExternalRuleResult 的参数、
 * 执行顺序 —— 全部保持原样。
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


/* ================== 字符① 取值来源换掉（其余不变） ================== */

// 获取型号：A 页面（档距段台账）关掉后，B 页面读不到它的节点，
// 所以改从 localStorage 读 A 页面存下的值。
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


/* ================== 字符② 外层判断 + 原判断逻辑原样 ================== */

if (typeNumber) {

    //判断型号包含导线截面吗
    if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {

        try { window[this.stepId + 'tyTipyShow'].hide(); } catch (e) { }

        insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });

    } else {

        let massage = '导线截面需要和型号匹配';

        /* 原来是直接 bootStrap.invoke('tyTipyShow', ...)，
           但它在这个代码页没有注册，会抛异常、把后面两条记录全带掉。
           加 try/catch 后：注册了就正常弹，没注册就静默跳过，记录照写。 */
        try { window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage); } catch (e) { }

        insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });

    }
}
/* 拿不到型号（A 页面还没填 / 缓存为空）→ 整体跳过，不校验、不弹提示、不记结果 */
