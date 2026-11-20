#!/usr/bin/env node
/**
 * spec-validate.js — AsyncAPI spec 语法/schema/$ref 校验（L6 DSL schema 校验）
 *
 * 用法: node spec-validate.js <spec.yaml> [spec2.yaml ...]
 *   输出: 每 spec 一行 JSON {file, ok, errors: [{level,message,path}]}
 *   退出码: 0=全通过, 1=任一失败
 *
 * 口径:
 *   - @asyncapi/parser 3.6.6（AsyncAPI 3.x 线，API=new Parser()+fromFile）
 *   - $ref 解析失败=硬错（parse 阶段）
 *   - diagnostic severity: error=fail, warning/info/hint 仅上报不 fail
 */
'use strict';
const fs = require('fs');
const path = require('path');

async function main() {
  const files = process.argv.slice(2);
  if (!files.length) {
    console.error('用法: node spec-validate.js <spec> [spec...]');
    process.exit(2);
  }
  let mod;
  try {
    mod = require('@asyncapi/parser');
  } catch (e) {
    console.error('FATAL: @asyncapi/parser 未安装（先 npm install）: ' + e.message);
    process.exit(4);
  }
  if (typeof mod.Parser !== 'function' || typeof mod.fromFile !== 'function') {
    console.error('FATAL: @asyncapi/parser 导出形态不符（Parser/fromFile 缺失，版本漂移）');
    process.exit(4);
  }
  const SEV = { 0: 'error', 1: 'warning', 2: 'info', 3: 'hint' };
  const diagLine = (d) => ({
    level: SEV[d.severity] || String(d.severity),
    message: String(d.message || '').slice(0, 300),
    path: (d.path || []).map(String).join('.'),
  });

  let rc = 0;
  for (const f of files) {
    const abs = path.resolve(f);
    if (!fs.existsSync(abs)) {
      console.error(JSON.stringify({ file: f, ok: false,
        errors: [{ level: 'error', message: '文件不存在', path: '' }] }));
      rc = 1;
      continue;
    }
    try {
      const parser = new mod.Parser();
      const { parse } = mod.fromFile(parser, abs);
      const out = await parse();
      const diags = out && out.diagnostics ? out.diagnostics : [];
      const errs = diags.map(diagLine);
      const hard = errs.filter(e => e.level === 'error');
      const ok = hard.length === 0;
      if (!ok) rc = 1;
      console.log(JSON.stringify({ file: f, ok, errors: errs }));
    } catch (e) {
      console.error(JSON.stringify({ file: f, ok: false,
        errors: [{ level: 'error', message: (e && e.message ? e.message : String(e)).slice(0, 500), path: '' }] }));
      rc = 1;
    }
  }
  process.exit(rc);
}

main().catch(e => { console.error('FATAL: ' + (e && e.message ? e.message : String(e))); process.exit(4); });
