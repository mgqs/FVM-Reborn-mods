/* ============================================================================
 * A 侧专用 · 写入（优先写 window.top，兼容 iframe 场景）
 *
 * 背景：控制台上下文是 top，而表单代码跑在 iframe 里。
 *      两者 window 不是同一个，加上 localStorage 不可用，
 *      所以必须显式写到 window.top 才能被另一个表单读到。
 *
 * 挂载位置：A 页面（档距段台账）→「型号」元素的 校验 / 值改变 / 失焦
 *         若型号元素没有校验配置项，就挂到 A 页面「保存」按钮脚本最前面
 * ========================================================================= */

const __v = (this.element && this.element.value !== undefined && this.element.value !== null)
    ? String(this.element.value).trim() : '';

if (__v) {
    // ① 写到顶层窗口（iframe 场景下两个表单共享的就是它）
    try { window.top['XH_DJDT_TYPE'] = __v; } catch (e) { }
    // ② 也写当前窗口，兼容不是 iframe 的情况
    try { window['XH_DJDT_TYPE'] = __v; } catch (e) { }
    // ③ 能存 storage 就再存一份
    try { if (window.localStorage) window.localStorage.setItem('XH_DJDT_TYPE', __v); } catch (e) { }
    try { if (window.sessionStorage) window.sessionStorage.setItem('XH_DJDT_TYPE', __v); } catch (e) { }
}
