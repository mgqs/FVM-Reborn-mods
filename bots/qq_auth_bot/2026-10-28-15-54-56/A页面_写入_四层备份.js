/* ============================================================================
 * A 页面（档距段台账 - 型号）专用 · 只负责"存"，不做任何校验、不弹任何提示
 *
 * 贴在哪里：A 页面「型号」元素的校验脚本最前面；没有校验配置就贴到 A 页面保存按钮
 *          脚本的最前面。位置要在能取到「型号」值的地方。
 *
 * 为什么写四层：
 *   localStorage 在你这个 Electron 环境里是 undefined（之前报过 reading 'getItem'），
 *   sessionStorage 大概率同样不可用。所以不能只赌一层，四层同时写，哪层能用就用哪层，
 *   任何一层不存在都不会报错、不会中断。
 *
 *   1. window.top    ← 父窗口，切换步骤时通常不会被销毁，最可能成功
 *   2. window        ← 当前 iframe，A 自己被销毁时一起没
 *   3. sessionStorage← 同标签页刷新后仍在，关标签页才清（若被禁用则跳过）
 *   4. localStorage  ← 最持久，但你这边可能不可用
 *
 * 这个脚本不会有任何输出、不会抛异常，因此不需要在 A 页面调试验证。
 * 是否写成功，去 B 页面读一次就能知道。
 * ========================================================================= */

(function () {
    var v = '';

    /* 取值：优先按节点名读，读不到就退回当前元素的值 */
    try {
        var nm = bootStrap.invoke('getNodeMap');
        var node = nm && nm.get ? nm.get('档距段台账') : null;
        var ele = node && node.get ? node.get('型号') : null;
        if (ele && ele.value !== undefined && ele.value !== null && ele.value !== '') {
            v = String(ele.value);
        }
    } catch (err) { }

    if (!v) {
        try {
            if (this && this.element && this.element.value !== undefined && this.element.value !== null) {
                v = String(this.element.value);
            }
        } catch (err) { }
    }

    if (!v) return;   /* 型号还是空的时候什么都不做，避免把空值写进去冲掉旧值 */

    /* 四层同时写，逐层独立 try，任何一层失败都不影响其他层 */
    try { if (window.top) window.top.XH_DJDT_TYPE = v; } catch (err) { }
    try { window.XH_DJDT_TYPE = v; } catch (err) { }
    try { if (window.sessionStorage) window.sessionStorage.setItem('XH_DJDT_TYPE', v); } catch (err) { }
    try { if (window.localStorage) window.localStorage.setItem('XH_DJDT_TYPE', v); } catch (err) { }
}).call(this);
