/* ============================================================================
 * 探针 · 短版（只输出一行，方便截图看清）
 *
 * 用法：整段替换代码页 → 在 A 页面（档距段台账）的「型号」里填值并失焦
 *      → 看控制台那条红色报错，一行就够：
 *
 *   [XH] step=2115... | node=档距段台账 | ele=型号 | val=JLKLY-150/20 | 缓存=空
 *
 * 需要的就是这四个：step / node / ele / val
 * 另外把同样这段代码放到 B 页面（导线截面）再跑一次，看那行里的 缓存= 后面有没有值。
 * ========================================================================= */

throw new Error(
    '[XH] step=' + this.stepId +
    ' | node=' + this.nodeName +
    ' | ele=' + this.elementName +
    ' | val=' + ((this.element && this.element.value === undefined) ? '无' : this.element.value) +
    ' | 缓存=' + ((function () {
        try {
            if (window['XH_DJDT_TYPE'] !== undefined) return String(window['XH_DJDT_TYPE']);
        } catch (e) { }
        try {
            if (window.localStorage) {
                const v = window.localStorage.getItem('XH_DJDT_TYPE');
                if (v !== null && v !== '') return String(v);
            }
        } catch (e) { }
        try {
            if (window.sessionStorage) {
                const v = window.sessionStorage.getItem('XH_DJDT_TYPE');
                if (v !== null && v !== '') return String(v);
            }
        } catch (e) { }
        return '空';
    })())
);
