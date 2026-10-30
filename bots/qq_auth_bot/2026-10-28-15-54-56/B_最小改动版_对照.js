/* ============================================================================
 * 相对你原代码的「最小改动版」
 *
 * 原则：你原来 if/else 里的 insertRecord / insertExternalRuleResult /
 *       tyTipyShow 四段调用一行都不改，只把 typeNumber 的来源换掉。
 *
 * 改动总量：
 *   B 页面   改 1 行 + 新增 6 行   （图2 第 52~53 行那一处）
 *   A 页面   新增 2 行             （原来完全没有，必须加，否则桥里没数据）
 *   crossPageBridge.js 新增文件
 * ========================================================================= */


/* ---------------------------------------------------------------------------
 * 【B 页面】耐张段台账 · 导线截面
 * ------------------------------------------------------------------------- */

/* ====== 你原来的代码（保持不动，仅作对照） ======
   //获取型号
   //let typeNumber = bootStrap.invoke('getNodeMap').get('耐张段台账').get('型号').value;
   //导线截面
   let typeNumber = bootStrap.invoke('getNodeMap').get('档距段台账').get('型号').value;   ← ★这一行改掉
   let thisElementValue = this.element.value;
   //判断型号包含导线截面吗
   if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {           ← 以下完全不改
       window[this.stepId + 'tyTipyShow'].hide();
       insertRecord({...});
       insertExternalRuleResult({...});
   } else {
       let massage = '导线截面需要和型号匹配';
       ...
   }
   ================================================ */

/* ====== 改后的写法：★ = 改动处，其余原样 ====== */

// ★新增 1：从桥里取 A 页面（档距段台账）写过缓存来的型号，A 关没关都能取到
FormBridge.setScope();
let modelList = FormBridge.get('DJDT_XH');
if (!Array.isArray(modelList)) { modelList = (modelList == null || modelList === '') ? [] : [modelList]; }

// ★改动 2：原来那一行 getNodeMap 换成"桥优先 + getNodeMap 兜底"（多型号用逗号拼起来，后面 includes 照旧）
let typeNumber = modelList.join(',');

// ★新增 3：A 页面此刻还开着时的兜底（保留你原来的取法，只是加了空值保护）
if (!typeNumber) {
  try {
    const n = bootStrap.invoke('getNodeMap').get('档距段台账');
    const e = n && n.get('型号');
    typeNumber = (e && e.value) ? String(e.value) : '';
  } catch (err) { typeNumber = ''; }
}

// ↓↓↓↓↓↓↓↓↓↓ 以下与你原代码完全一致，一字未改 ↓↓↓↓↓↓↓↓↓↓
let thisElementValue = this.element.value;

//判断型号包含导线截面吗
if (typeNumber.includes(thisElementValue) && thisElementValue.length > 0) {
  window[this.stepId + 'tyTipyShow'].hide();
  insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
  //保存时强制校验
  insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });
} else {
  let massage = '导线截面需要和型号匹配';
  window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage);
  insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
  //保存时强制校验
  insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
}


/* ---------------------------------------------------------------------------
 * 【A 页面】档距段台账 · 型号  —— 原来没有这段，新增 2 行
 * 放在「型号」元素的值改变 / 失焦 / 校验脚本里（放保存按钮里也行，但会被校验拦住）
 * ------------------------------------------------------------------------- */
FormBridge.setScope();                              // ★新增
FormBridge.push('DJDT_XH', this.element.value);     // ★新增（push 会累积多行台账的型号，自动去重）


/* ---------------------------------------------------------------------------
 * 【改动清单】
 *
 * ┌───┬──────────────────────────────────────────┬──────────┬────────────┐
 * │ # │ 位置                                      │ 类型     │ 行数       │
 * ├───┼──────────────────────────────────────────┼──────────┼────────────┤
 * │ 1 │ B：新增桥取值 + 兜底                       │ 新增     │ +6         │
 * │ 2 │ B：let typeNumber = getNodeMap(...)       │ 替换     │ 1 → 1      │
 * │ 3 │ B：if/else 四段 insertRecord 等            │ 不动     │ 0          │
 * │ 4 │ A：型号元素写入桥                          │ 新增     │ +2         │
 * │ 5 │ 公共库 crossPageBridge.js                 │ 新增文件  │ —          │
 * └───┴──────────────────────────────────────────┴──────────┴────────────┘
 *
 * 你图1 里那段代码（insertRecord / insertExternalRuleResult / getTime）
 * 一行都不用动 —— 它们只是"写日志 / 弹提示"的工具函数，跟取值无关。
 * ------------------------------------------------------------------------- */
