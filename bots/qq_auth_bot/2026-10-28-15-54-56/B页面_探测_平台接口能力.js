/* ============================================================================
 * 一次性探测 · 只在 B 页面（耐张段台账-导线截面）执行
 *
 * 目的：A 页面不能挂代码、也不能验证，所以必须由 B 页面自己去把 A 的值捞回来。
 *      这个脚本一次性摸清 B 页面到底有哪些取数通道可用。
 *
 * 用法：把代码页整段替换成这个文件 → 在 B 页面「导线截面」输入任意内容触发校验
 *      → 看控制台红色报错，开头是 [XH-P]，内容是 JSON。
 *
 * 看完结果后，把这条报错整段发我（右键 → Copy message），我按结果改正式版。
 * ========================================================================= */

(function () {
    var ctx = this || {};
    var r = {};

    /* ① 当前上下文：确认 B 页面到底是哪个 step / node / element */
    r.上下文 = (ctx.stepName || '?') + ' / ' + (ctx.nodeName || '?') + ' / ' + (ctx.elementName || '?');
    r.标识 = 'stepId=' + ctx.stepId + ' | nodeId=' + ctx.nodeId + ' | elementId=' + ctx.elementId;

    /* ② 平台是否提供"跨步骤 / 跨节点取数"的接口
          —— 做法是逐个试名字：报 "not registered" 的说明不存在，能调用或报参数错的说明存在 */
    var cands = [
        'getNodeMap',
        'getStepData', 'getStepList', 'getFormData', 'getFormStepData',
        'getAllData', 'getData', 'getNodeValue', 'getElementValue',
        'getStepValue', 'getHistoryData', 'getFlowData', 'getInstanceData',
        'getTaskData', 'getBusiData', 'getTableData', 'getRecordList',
        'queryData', 'requestData', 'getDataSource', 'getStepNodeMap'
    ];
    var usable = [];
    var missing = [];
    for (var i = 0; i < cands.length; i++) {
        var n = cands[i];
        try {
            bootStrap.invoke(n);
            usable.push(n);
        } catch (e) {
            var m = String((e && e.message) || e);
            if (/not registered|未注册|not exist|is not a function/i.test(m)) {
                missing.push(n);
            } else {
                /* 报参数错 / 返回空 都说明这个接口是存在的，只是用法不对 */
                usable.push(n + ' [报:' + m.slice(0, 24) + ']');
            }
        }
    }
    r.可用接口 = usable.join(', ');
    r.不存在 = missing.length + ' 个（' + missing.slice(0, 6).join(',') + '...）';

    /* ③ 当前能看到的节点，以及 A 页面的内容在不在这个文档里 */
    try {
        var nm = bootStrap.invoke('getNodeMap');
        var names = [];
        if (nm && typeof nm.forEach === 'function') {
            nm.forEach(function (v, k) { names.push(k); });
        } else if (nm) {
            names = Object.keys(nm);
        }
        r.可见节点 = names.join(', ') || '(空)';
    } catch (e) {
        r.可见节点 = 'ERR ' + e.message;
    }

    try {
        var html = document.documentElement.innerHTML;
        r.文档里有_档距段台账 = html.indexOf('档距段台账') !== -1;
        r.文档里有_型号 = html.indexOf('型号') !== -1;
        r.iframe数 = document.querySelectorAll('iframe').length;
    } catch (e) {
        r.文档检测 = 'ERR ' + e.message;
    }

    /* ④ 通道能力：window 层级、存储、网络请求 */
    try { r.是顶层窗口 = (window === window.top); } catch (e) { r.是顶层窗口 = 'ERR'; }
    try { r.localStorage = typeof window.localStorage; } catch (e) { r.localStorage = 'ERR'; }
    try { r.fetch = typeof fetch; } catch (e) { r.fetch = 'ERR'; }
    try { r.XHR = typeof XMLHttpRequest; } catch (e) { r.XHR = 'ERR'; }

    /* ⑤ window 上可疑的全局对象（平台可能把整份表单数据挂在这里） */
    try {
        var keys = Object.keys(window).filter(function (k) {
            return /data|form|step|node|table|busi|store|cache|flow|instance|context|ctx|vm|store/i.test(k);
        }).slice(0, 18);
        r.候选全局 = keys.join(', ') || '(无)';
    } catch (e) {
        r.候选全局 = 'ERR';
    }

    throw new Error('[XH-P] ' + JSON.stringify(r));
}).call(this);
