/* ============================================================================
 * crossPageBridge.js —— 跨页面取值桥
 *
 * 解决的问题：
 *   bootStrap.invoke('getNodeMap') 只能读到“当前仍然打开”的节点。
 *   A 页面（档距段台账）关闭后，B 页面（耐张段台账）再取 A 的节点就取不到了。
 *
 * 做法：
 *   A 页面把值写入桥  →  桥落盘到 localStorage（同时留一份 window 内存）
 *   B 页面从桥里读    →  A 页面关没关、刷没刷新都不影响
 *
 * 放在哪里：
 *   1) 平台支持“公共脚本/自定义 JS” → 放公共脚本里，A/B 页面自动可用；
 *   2) 不支持 → 把本文件整段分别贴在 A、B 两个页面脚本的最前面（重复定义无害，
 *      因为内部只会在 window 上挂一个 FormBridge）。
 * ========================================================================= */
(function (global) {
  'use strict';

  var NS = 'FORM_BRIDGE_V1';          // localStorage 里的命名空间
  var DEFAULT_TTL = 8 * 60 * 60 * 1000; // 默认 8 小时过期，可按需改

  var memory = null; // localStorage 不可用（隐私模式 / 配额满）时的内存兜底

  function readAll() {
    var raw = null;
    try { raw = global.localStorage.getItem(NS); } catch (e) { raw = null; }
    if (raw) {
      try {
        var obj = JSON.parse(raw);
        if (obj && typeof obj === 'object') return obj;
      } catch (e) { /* 坏数据，忽略 */ }
    }
    return memory || {};
  }

  function writeAll(obj) {
    memory = obj;
    try { global.localStorage.setItem(NS, JSON.stringify(obj)); } catch (e) { /* 退化为内存 */ }
  }

  var Bridge = {
    _scope: '',

    /* ------------------------------------------------------------------
     * 业务隔离维度：工程编号 / 线路名称 等
     * 作用：同一个浏览器里先后录入多个工程时，不会串数据。
     * 取值规则 A / B 页面必须完全一致（本方法对两个页面通用）。
     * ⚠️ 下面三个候选字段是示例，请换成你表单里真实存在的节点名 + 元素名。
     * ------------------------------------------------------------------ */
    resolveScope: function () {
      try {
        if (typeof bootStrap === 'undefined') return '';
        var nm = bootStrap.invoke('getNodeMap');
        var cands = [
          ['工程信息', '工程编号'],
          ['工程信息', '线路名称'],
          ['基本信息', '线路名称']
        ];
        for (var i = 0; i < cands.length; i++) {
          var node = nm.get(cands[i][0]);
          var ele = node && node.get(cands[i][1]);
          if (ele && ele.value !== undefined && ele.value !== null && ele.value !== '') {
            return String(ele.value).trim();
          }
        }
      } catch (e) { /* 取不到就用全局作用域 */ }
      return '';
    },

    /** 设置作用域；不传参则自动解析 */
    setScope: function (scope) {
      this._scope = (scope === undefined || scope === null) ? this.resolveScope() : String(scope);
      return this._scope;
    },

    getScope: function () { return this._scope; },

    _key: function (k) { return this._scope ? this._scope + '::' + k : k; },

    /** 覆盖写入 */
    set: function (k, value) {
      var all = readAll();
      all[this._key(k)] = { v: value, t: Date.now() };
      writeAll(all);
      return value;
    },

    /** 读取；ttl 传 0 表示永不过期 */
    get: function (k, ttl) {
      var all = readAll();
      var item = all[this._key(k)];
      if (!item) return undefined;
      var life = (ttl === undefined) ? DEFAULT_TTL : ttl;
      if (life > 0 && (Date.now() - item.t) > life) {
        delete all[this._key(k)];
        writeAll(all);
        return undefined;
      }
      return item.v;
    },

    /** 追加（A 页面有多行台账时用），自动去重 */
    push: function (k, value) {
      var list = this.get(k);
      if (!Array.isArray(list)) list = (list === undefined || list === null || list === '') ? [] : [list];
      var v = String(value == null ? '' : value).trim();
      if (v && list.indexOf(v) === -1) list.push(v);
      this.set(k, list);
      return list;
    },

    remove: function (k) {
      var all = readAll();
      delete all[this._key(k)];
      writeAll(all);
    },

    /** 清掉当前作用域下的全部键（切换工程 / 新建工程时调用） */
    clearScope: function () {
      var all = readAll();
      var prefix = this._scope ? this._scope + '::' : null;
      Object.keys(all).forEach(function (k) {
        if (!prefix || k.indexOf(prefix) === 0) delete all[k];
      });
      writeAll(all);
    },

    clearAll: function () { writeAll({}); },

    /** 调试：控制台里 FormBridge.dump() 看当前都有什么 */
    dump: function () { return readAll(); }
  };

  global.FormBridge = Bridge;
  if (!global.__FORM_BRIDGE_READY__) global.__FORM_BRIDGE_READY__ = true;

})(window);
