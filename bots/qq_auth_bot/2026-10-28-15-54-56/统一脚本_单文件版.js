/* ============================================================================
 * 统一脚本 · 单文件版（只有一处代码页时用这个）
 *
 * 思路：只有一份代码，内部按"当前所在的节点名 / 元素名"自动分流
 *      · 在【档距段台账-型号】上执行   → 走 A 分支：把型号写进缓存
 *      · 在【耐张段台账-导线截面】上执行 → 走 B 分支：从缓存取型号，做比对
 *      · 其他元素                      → 什么都不做，直接放过
 *
 * 挂载位置：
 *   方式一（推荐）：挂到「型号」和「导线截面」两个元素的 值改变 / 失焦 / 校验 上
 *                  两个元素挂同一段代码，代码自己判断走哪边。
 *   方式二：如果平台只有一个"保存校验入口"给所有元素共用，把下面
 *          ATTACH_MODE 改成 'save'，并确保能通过节点名取到值。
 *
 * 自包含：缓存库直接内联在本文件里，不需要额外引入任何文件。
 * ========================================================================= */

(function () {
  'use strict';

  /* ========================= ① 配置区（只改这里） ========================= */
  var CFG = {
    A_NODE: '档距段台账',        // A 页面节点名
    A_ELE:  '型号',              // A 页面元素名
    B_NODE: '耐张段台账',        // B 页面节点名
    B_ELE:  '导线截面',          // B 页面元素名
    KEY:    'DJDT_XH',           // 缓存键名，随便起，两边一致即可
    TTL_H:  8,                   // 缓存有效期（小时）

    // 业务隔离维度：同一个浏览器编辑多个工程时不串数据。
    // ⚠️ 换成你表单里真实存在的 节点名+元素名；A/B 两处必须取到同一个值。
    SCOPE_FIELDS: [
      ['工程信息', '工程编号'],
      ['工程信息', '线路名称'],
      ['基本信息', '线路名称']
    ],

    ATTACH_MODE: 'element',      // 'element' = 挂在字段元素上；'save' = 挂在保存校验入口
    DEBUG: false                 // 调通阶段改成 true，控制台能看到它判断成了哪一边
  };
  /* ====================================================================== */

  var ctx = this; // 元素上下文：elementName / nodeName / stepId / stepName ...

  /* ---------------- ② 取值 & 名称识别 ---------------- */
  function safeGet(o, p) {
    try { return o ? o[p] : undefined; } catch (e) { return undefined; }
  }

  function nodeMap() {
    try { return bootStrap.invoke('getNodeMap'); } catch (e) { return null; }
  }

  function readByNodeName(nName, eName) {
    try {
      var nm = nodeMap();
      var node = nm && nm.get(nName);
      var ele = node && node.get(eName);
      return ele && ele.value !== undefined ? ele.value : undefined;
    } catch (e) { return undefined; }
  }

  var elName = String(safeGet(ctx, 'elementName') || safeGet(safeGet(ctx, 'element'), 'elementName') || '');
  var nodeName = String(safeGet(ctx, 'nodeName') || safeGet(safeGet(ctx, 'element'), 'nodeName') || '');

  function same(a, b) { return !!a && !!b && (a === b || a.indexOf(b) !== -1 || b.indexOf(a) !== -1); }

  var isBNode = same(nodeName, CFG.B_NODE);
  var isANode = same(nodeName, CFG.A_NODE);
  var isBEle = same(elName, CFG.B_ELE);
  var isAEle = same(elName, CFG.A_ELE);

  // 判断方向：节点名优先（B 页面上也可能有"型号"元素，不能只看元素名）
  var role = '';
  if (isBNode) role = 'B';
  else if (isANode) role = 'A';
  else if (isBEle) role = 'B';
  else if (isAEle) role = 'A';

  // 挂载模式：element 模式要求元素名也对上；save 模式不限制元素名，靠节点名取值
  if (CFG.ATTACH_MODE === 'element' && role) {
    if (role === 'A' && !isAEle && elName) role = '';
    if (role === 'B' && !isBEle && elName) role = '';
  }

  if (CFG.DEBUG) {
    console.log('[跨页校验] nodeName=', nodeName, 'elementName=', elName, '→ role=', role || '不动');
  }

  if (!role) return;

  /* ---------------- ③ 内联缓存库（window 单例，多次执行不会重复创建） ---------------- */
  var Bridge = window.__FORM_BRIDGE__;
  if (!Bridge) {
    Bridge = (function () {
      var NS = 'FORM_BRIDGE_V1';
      var mem = null;

      function readAll() {
        var raw = null;
        try { raw = window.localStorage.getItem(NS); } catch (e) { raw = null; }
        if (raw) { try { var o = JSON.parse(raw); if (o && typeof o === 'object') return o; } catch (e) {} }
        return mem || {};
      }
      function writeAll(o) {
        mem = o;
        try { window.localStorage.setItem(NS, JSON.stringify(o)); } catch (e) {}
      }

      var b = {
        _scope: '',
        setScope: function (s) {
          if (s !== undefined && s !== null) { this._scope = String(s); return this._scope; }
          var v = '';
          for (var i = 0; i < CFG.SCOPE_FIELDS.length; i++) {
            var t = readByNodeName(CFG.SCOPE_FIELDS[i][0], CFG.SCOPE_FIELDS[i][1]);
            if (t !== undefined && t !== null && String(t).trim() !== '') { v = String(t).trim(); break; }
          }
          this._scope = v;
          return v;
        },
        _k: function (k) { return this._scope ? this._scope + '::' + k : k; },
        set: function (k, v) { var a = readAll(); a[this._k(k)] = { v: v, t: Date.now() }; writeAll(a); return v; },
        get: function (k) {
          var a = readAll(), it = a[this._k(k)];
          if (!it) return undefined;
          if (CFG.TTL_H > 0 && (Date.now() - it.t) > CFG.TTL_H * 3600000) { delete a[this._k(k)]; writeAll(a); return undefined; }
          return it.v;
        },
        push: function (k, v) {
          var list = this.get(k);
          if (!Array.isArray(list)) list = (list === undefined || list === null || list === '') ? [] : [list];
          var s = String(v == null ? '' : v).trim();
          if (s && list.indexOf(s) === -1) list.push(s);
          this.set(k, list);
          return list;
        },
        remove: function (k) { var a = readAll(); delete a[this._k(k)]; writeAll(a); },
        clearScope: function () {
          var a = readAll(), p = this._scope ? this._scope + '::' : null;
          Object.keys(a).forEach(function (k) { if (!p || k.indexOf(p) === 0) delete a[k]; });
          writeAll(a);
        }
      };
      return b;
    })();
    window.__FORM_BRIDGE__ = Bridge;
  }

  /* ---------------- ④ 日志工具（沿用你原来的写法，未改） ---------------- */
  function logRecord(inputContent, prompt, triggerStatus) {
    insertRecord({ inputContent: inputContent, prompt: prompt, forceSave: false, triggerStatus: triggerStatus, codeCtx: ctx, time: new Date() });
    insertExternalRuleResult({ inputContent: inputContent, prompt: prompt, triggerStatus: triggerStatus, codeCtx: ctx, time: new Date() });
  }

  Bridge.setScope();

  /* ---------------- ⑤ A 分支：档距段台账-型号 → 写入缓存 ---------------- */
  function doA() {
    var v = (safeGet(ctx, 'element') && safeGet(ctx.element, 'value') !== undefined)
      ? ctx.element.value
      : readByNodeName(CFG.A_NODE, CFG.A_ELE);

    var s = String(v == null ? '' : v).trim();
    if (s) {
      Bridge.push(CFG.KEY, s);
      if (CFG.DEBUG) console.log('[跨页校验] A 已缓存型号：', Bridge.get(CFG.KEY));
    }
  }

  /* ---------------- ⑥ B 分支：耐张段台账-导线截面 → 读取并比对 ---------------- */
  function doB() {
    var v = (safeGet(ctx, 'element') && safeGet(ctx.element, 'value') !== undefined)
      ? ctx.element.value
      : readByNodeName(CFG.B_NODE, CFG.B_ELE);

    var thisElementValue = String(v == null ? '' : v).trim();

    // 取 A 页面型号：先读缓存，取不到再兜底走 getNodeMap（A 还开着的情况）
    var list = Bridge.get(CFG.KEY);
    if (!Array.isArray(list)) list = (list === undefined || list === null || list === '') ? [] : [list];

    if (list.length === 0) {
      var direct = readByNodeName(CFG.A_NODE, CFG.A_ELE);
      if (direct !== undefined && direct !== null && String(direct).trim() !== '') {
        list = String(direct).split(/[,，、;；\s]+/);
      }
    }

    var typeNumber = list.map(function (x) { return String(x == null ? '' : x).trim(); })
      .filter(function (x) { return x; }).join(',');

    if (CFG.DEBUG) console.log('[跨页校验] B 读到 A 型号 =', typeNumber, '｜当前导线截面 =', thisElementValue);

    // ↓↓↓ 以下比对与提示逻辑，与你原来那段完全一致 ↓↓↓
    if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
      window[ctx.stepId + 'tyTipyShow'].hide();
      logRecord(thisElementValue, '', false);
    } else {
      var massage = '导线截面需要和型号匹配';
      window[ctx.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', ctx, massage);
      logRecord(thisElementValue, massage, true);
    }
  }

  /* ---------------- ⑦ 分流执行 ---------------- */
  if (role === 'A') doA();
  else if (role === 'B') doB();

})();
