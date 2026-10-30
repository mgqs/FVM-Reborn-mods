/* ============================================================================
 * 探针 v2 · 用"报错"输出诊断信息（列出每个节点下每个元素的值）
 *
 * v2 相比 v1：不只看元素名，还把每个元素的值都打出来。
 *            因为在 B 页面实测发现 node.get('导线截面') 取不到，
 *            但 this.element.value 是有值的（"3"），所以要对比着看。
 *
 * 用法：整段替换代码页 → 触发校验 → 看控制台红色报错 [XH] {...}
 *      先在 A 页面（档距段台账-型号）触发一次，再在 B 页面触发一次。
 *
 * 报错里带：
 *   stepId / stepName / nodeId / nodeName / elementId / elementName
 *   当前值              → this.element.value
 *   缓存                → window['XH_DJDT_TYPE']
 *   节点列表            → getNodeMap 里真实有几个节点
 *   节点元素值          → { 节点: { 元素: 值 } }   ← 最关键
 * ========================================================================= */

const __xh = {};

__xh.stepId = this.stepId;
__xh.stepName = this.stepName;
__xh.nodeId = this.nodeId;
__xh.nodeName = this.nodeName;
__xh.elementId = this.elementId;
__xh.elementName = this.elementName;
__xh.当前值 = (this.element && this.element.value !== undefined) ? this.element.value : '(没有 element)';

try {
    __xh.缓存 = (window['XH_DJDT_TYPE'] === undefined) ? '(未写入)' : window['XH_DJDT_TYPE'];
} catch (e) {
    __xh.缓存 = 'ERR:' + e.message;
}

function __xh_keys(o) {
    if (!o) return [];
    if (o instanceof Map) return Array.from(o.keys());
    if (typeof o.keys === 'function') return Array.from(o.keys());
    return Object.keys(o);
}

try {
    const nm = bootStrap.invoke('getNodeMap');
    const nodeKeys = __xh_keys(nm);
    __xh.节点列表 = nodeKeys;

    const all = {};
    for (let i = 0; i < nodeKeys.length; i++) {
        const nk = nodeKeys[i];
        try {
            const node = nm.get(nk);
            const eleKeys = __xh_keys(node);
            const vals = {};
            for (let j = 0; j < eleKeys.length; j++) {
                const ek = eleKeys[j];
                try {
                    const ele = node.get(ek);
                    vals[ek] = ele ? ele.value : '(ele 为空)';
                } catch (err) {
                    vals[ek] = 'ERR:' + err.message;
                }
            }
            all[nk] = vals;
        } catch (err) {
            all[nk] = 'ERR:' + err.message;
        }
    }
    __xh.节点元素值 = all;
} catch (e) {
    __xh.节点信息 = 'ERR:' + e.message;
}

try { window.__XH_DBG__ = __xh; } catch (e) { }

throw new Error('[XH] ' + JSON.stringify(__xh));
