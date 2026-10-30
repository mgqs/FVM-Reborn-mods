/* ============================================================================
 * A 页面（档距段台账 - 型号）· 把型号写进 localStorage
 *
 * 贴在哪里：A 页面「型号」元素的校验脚本最前面；没有校验配置就贴到 A 页面
 *          「保存 / 下一步」按钮脚本的最前面。
 *
 * localStorage 的生命周期正好符合你的需求：
 *   A 关掉 → B 打开：不清
 *   页面刷新：不清
 *   浏览器整个关闭再打开：不清
 *   只有手动 clear、清浏览器数据、或无痕窗口关闭才清 → 因此不需要设过期时间。
 * ========================================================================= */

try {
    /* 主路径：按节点名取 —— A 页面里档距段台账是打开着的，这里能取到 */
    var xhType = bootStrap.invoke('getNodeMap').get('档距段台账').get('型号').value;
    if (xhType) {
        window.localStorage.setItem('XH_DJDT_TYPE', String(xhType));
    }
} catch (e) {
    /* 兜底：节点名或元素名对不上时，直接用当前元素自身的值 */
    try {
        var xhType2 = this.element.value;
        if (xhType2) {
            window.localStorage.setItem('XH_DJDT_TYPE', String(xhType2));
        }
    } catch (e2) { }
}
