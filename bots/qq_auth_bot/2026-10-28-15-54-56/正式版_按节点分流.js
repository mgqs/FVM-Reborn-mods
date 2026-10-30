/* ============================================================================
 * 正式版 · 按节点名分流（不依赖 stepId，不需要再试探针）
 *
 * 依据上次探针拿到的真实数据：
 *   B 页面：nodeName = "耐张段台账"，elementName = "导线截面"
 *   节点列表只有 ["耐张段台账"]  → 两个表单的 getNodeMap 互不可见，
 *   所以必须靠"存起来再读"，这就是本文件在做的事。
 *
 * 分流规则：
 *   nodeName 含"档距段台账"          → A 侧：把型号写进缓存
 *   nodeName 含"耐张段台账" + 导线截面 → B 侧：读缓存 + 比对 + 弹提示
 *   其他                              → 什么都不做
 *
 * 这样在 A 页面上永远不会去调 tyTipyShow，也就不会再报
 * "Fucntion tyTipyShow is not registered"。
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


/* ================== 存取工具（三级降级，不会抛异常） ================== */

const XH_KEY = 'XH_DJDT_TYPE';

/* 顶层窗口：表单跑在 iframe 里时，两个表单共享的是 top，
   而 localStorage 在这环境不可用，所以 top 是唯一可靠的共享位。 */
function xhTopWin() {
    try { return window.top || null; } catch (e) { return null; }
}

function xhSet(key, value) {
    try { const t = xhTopWin(); if (t) t[key] = value; } catch (e) { }
    try { window[key] = value; } catch (e) { }
    try { if (window.localStorage) window.localStorage.setItem(key, value); } catch (e) { }
    try { if (window.sessionStorage) window.sessionStorage.setItem(key, value); } catch (e) { }
}

function xhGet(key) {
    try {
        const t = xhTopWin();
        const v = t ? t[key] : undefined;
        if (v !== undefined && v !== null && v !== '') return String(v);
    } catch (e) { }
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


/* ================== 当前上下文 + 分流判断 ================== */

const _nodeName = this.nodeName || '';
const _eleName = this.elementName || '';
const _curValue = (this.element && this.element.value !== undefined && this.element.value !== null)
    ? String(this.element.value) : '';

const _isA = _nodeName.indexOf('档距段台账') !== -1;
const _isB = _nodeName.indexOf('耐张段台账') !== -1;

// 在当前节点里按元素名取值（取不到返回 ''）
function xhNodeEleValue(elementName) {
    try {
        const nm = bootStrap.invoke('getNodeMap');
        const node = nm && nm.get(_nodeName);
        const ele = node && node.get(elementName);
        return (ele && ele.value != null) ? String(ele.value) : '';
    } catch (e) {
        return '';
    }
}


/* ================== A 侧：档距段台账 → 把型号存起来 ================== */
/* 两种挂载方式都能兼容：
   · 代码挂在「型号」元素上 → 直接用 this.element.value
   · 代码挂在别的元素/按钮上 → 按元素名去当前节点里读「型号」     */

if (_isA) {
    let _model = (_eleName === '型号') ? _curValue : xhNodeEleValue('型号');
    if (!_model && _eleName !== '型号') _model = xhNodeEleValue('型号');
    if (_model) {
        xhSet(XH_KEY, _model);
    }
}


/* ================== B 侧：耐张段台账-导线截面 → 读取 + 比对 ================== */

if (_isB && _eleName === '导线截面') {

    // 获取型号（替代原来那句会抛异常的 getNodeMap 链式取值）
    let typeNumber = xhGet(XH_KEY);
    if (!typeNumber) typeNumber = xhNodeEleValue('型号');

    let thisElementValue = _curValue;

    //判断型号包含导线截面吗
    if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
        try { if (window[this.stepId + 'tyTipyShow']) window[this.stepId + 'tyTipyShow'].hide(); } catch (e) { }
        insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });
    } else {
        let massage = typeNumber
            ? ('导线截面需要和型号匹配（档距段台账型号：' + typeNumber + '）')
            : '未获取到档距段台账的型号，请先填写档距段台账';
        try { window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage); } catch (e) { }
        insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
        //保存时强制校验
        insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
    }
}


/* ============================================================================
 * 如果 B 页面一直提示"未获取到档距段台账的型号"，说明 A 侧没写进去。
 * 那说明这段代码在 A 页面没有被触发，请改用 探针_短版.js 跑一次确认。
 *
 * 已知限制：
 *   · 换工程会读到上一个工程的型号 → 切换工程时执行 xhSet(XH_KEY, '')
 *   · A 改了型号但没触发校验 → 缓存里还是旧值
 * ========================================================================= */
