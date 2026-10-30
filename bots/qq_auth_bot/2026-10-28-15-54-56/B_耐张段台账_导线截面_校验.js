/* ============================================================================
 * B 页面：耐张段台账 · 导线截面 校验（整段替换你图片里 50~65 行那段）
 *
 * 规则：B 的【导线截面】必须能在 A【档距段台账-型号】里匹配到
 * 数据来源（按优先级）：
 *   1) 跨页面桥 FormBridge（A 页面事先写入的，A 关闭后依然可读）
 *   2) 兜底 getNodeMap（A 页面此刻还开着的情况）—— 已加空值保护
 *   3) 两者都没有 → 明确提示"请先填写档距段台账"，不静默放过
 * ========================================================================= */

// ① 定作用域（必须与 A 页面一致）
FormBridge.setScope();

// ② 当前录入值
const thisElementValue = String(this.element && this.element.value != null ? this.element.value : '').trim();

// ③ 优先从桥里取 A 页面存过的型号
let modelList = FormBridge.get('DJDT_XH');
if (!Array.isArray(modelList)) {
  modelList = (modelList === undefined || modelList === null || modelList === '') ? [] : [modelList];
}

// ④ 兜底：A 页面还开着，直接读节点（注意：节点或元素不存在时不要炸）
if (modelList.length === 0) {
  try {
    const node = bootStrap.invoke('getNodeMap').get('档距段台账');
    const ele = node && node.get('型号');
    const v = ele && ele.value;
    if (v) modelList = Array.isArray(v) ? v.slice() : String(v).split(/[,，、;；\s]+/);
  } catch (err) {
    // A 页面已关闭，节点不存在，属正常情况，忽略
  }
}

// ⑤ 归一化：去空、去重
const models = [];
modelList.forEach(function (v) {
  const s = String(v == null ? '' : v).trim();
  if (s && models.indexOf(s) === -1) models.push(s);
});

// ⑥ A 页面数据缺失 → 明确提示（这一步千万别省，否则会被当成"校验通过"或误报）
if (models.length === 0) {
  const massage = '未获取到【档距段台账-型号】，请先填写并保存档距段台账后再录入导线截面';
  window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage);
  insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
  insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
}
// ⑦ 有 A 的数据 → 正常比对：任一档距段型号包含当前导线截面即通过
else {
  const matched = thisElementValue.length > 0 && models.some(function (m) {
    return m.indexOf(thisElementValue) !== -1;
  });

  if (matched) {
    if (window[this.stepId + 'tyTipyShow']) window[this.stepId + 'tyTipyShow'].hide();
    insertRecord({ inputContent: thisElementValue, prompt: '', forceSave: false, triggerStatus: false, codeCtx: this, time: new Date() });
    insertExternalRuleResult({ inputContent: thisElementValue, prompt: '', triggerStatus: false, codeCtx: this, time: new Date() });
  } else {
    const massage = '导线截面需要和型号匹配，档距段台账中的型号为：' + models.join('、');
    window[this.stepId + 'tyTipyShow'] = bootStrap.invoke('tyTipyShow', this, massage);
    insertRecord({ inputContent: thisElementValue, prompt: massage, forceSave: false, triggerStatus: true, codeCtx: this, time: new Date() });
    insertExternalRuleResult({ inputContent: thisElementValue, prompt: massage, triggerStatus: true, codeCtx: this, time: new Date() });
  }
}
