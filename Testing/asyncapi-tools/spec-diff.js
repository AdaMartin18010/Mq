#!/usr/bin/env node
// spec-diff.js — L6（业务场景→测试验证环）spec 版本差分 / breaking change 检测
// 基于 @asyncapi/diff 0.6.1 库 API（该包无 CLI，故走库封装；diff() 同步返回 DiffResult）。
// DiffResult 方法: breaking() / nonBreaking() / unclassified()，各返回
//   [{ action, path, before?, after?, type }] 数组。
// 用法: node spec-diff.js <old.yaml> <new.yaml>
// 退出码: 0=无 breaking / 1=有 breaking / 2=参数错 / 3=解析或 diff 执行错
const fs = require('fs');
const yaml = require('js-yaml');
const { diff } = require('@asyncapi/diff');

function main() {
  const args = process.argv.slice(2).filter((a) => !a.startsWith('--'));
  if (args.length < 2) {
    console.error('usage: spec-diff.js <old.yaml> <new.yaml>');
    process.exit(2);
  }
  let oldSpec, newSpec;
  try {
    oldSpec = yaml.load(fs.readFileSync(args[0], 'utf8'));
    newSpec = yaml.load(fs.readFileSync(args[1], 'utf8'));
  } catch (e) {
    console.error('LOAD_ERROR: ' + e.message);
    process.exit(3);
  }
  let res;
  try {
    res = diff(oldSpec, newSpec);
  } catch (e) {
    console.error('DIFF_ERROR: ' + (e && e.message ? e.message : e));
    process.exit(3);
  }
  const breaking = res.breaking() || [];
  const nonBreaking = res.nonBreaking() || [];
  const unclassified = res.unclassified ? res.unclassified() || [] : [];
  console.log(`breaking: ${breaking.length}`);
  console.log(`non-breaking: ${nonBreaking.length}`);
  if (unclassified.length) console.log(`unclassified: ${unclassified.length}`);
  for (const c of breaking) {
    console.log(`  [BREAKING] ${c.action} ${c.path}`);
  }
  for (const c of nonBreaking) {
    console.log(`  [non-breaking] ${c.action} ${c.path}`);
  }
  for (const c of unclassified) {
    console.log(`  [unclassified] ${c.action} ${c.path}`);
  }
  process.exit(breaking.length ? 1 : 0);
}

main();
