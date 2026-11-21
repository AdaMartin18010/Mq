#!/usr/bin/env node
// 跨语言金样本投影客户端（Node，批次189）
// 用法:
//   node project_emit.js project <in.jsonl> <out.jsonl>   精确字面量投影
//   node project_emit.js emit    <in.jsonl> <out.jsonl>   默认编码器再序列化
// project 模式用手写 JSON 扫描器捕获数字精确字面量（JSON.parse 会把 >2^53 整数塌缩为 float64，
// 无法区分"原文写的是 int 还是 float"，故不能直接用于投影）。
'use strict';
const fs = require('fs');

class Scanner {
  constructor(s) { this.s = s; this.pos = 0; }
  skipWs() {
    while (this.pos < this.s.length && ' \t\r\n'.includes(this.s[this.pos])) this.pos++;
  }
  parseString() {
    const s = this.s;
    if (s[this.pos] !== '"') throw new Error('expected string at ' + this.pos);
    this.pos++;
    let out = '';
    while (this.pos < s.length) {
      const c = s[this.pos++];
      if (c === '"') return out;
      if (c === '\\') {
        const e = s[this.pos++];
        if (e === 'u') {
          const hex = s.slice(this.pos, this.pos + 4);
          this.pos += 4;
          out += String.fromCharCode(parseInt(hex, 16));
          continue;
        }
        const map = { '"': '"', '\\': '\\', '/': '/', b: '\b', f: '\f', n: '\n', r: '\r', t: '\t' };
        if (!(e in map)) throw new Error('bad escape \\' + e);
        out += map[e];
      } else {
        out += c;
      }
    }
    throw new Error('unterminated string');
  }
  parseNumber(f, path) {
    const m = /^-?(0|[1-9]\d*)(\.\d+)?([eE][+-]?\d+)?/.exec(this.s.slice(this.pos));
    if (!m) throw new Error('bad number at ' + this.pos);
    const lit = m[0];
    this.pos += lit.length;
    f[path] = ['num', lit, String(Number(lit))];
  }
  parseValue(f, path) {
    this.skipWs();
    const c = this.s[this.pos];
    if (c === '{') {
      this.pos++;
      const entries = {};
      for (;;) {
        this.skipWs();
        if (this.s[this.pos] === '}') { this.pos++; break; }
        const key = this.parseString();
        this.skipWs();
        if (this.s[this.pos] !== ':') throw new Error('expected : at ' + this.pos);
        this.pos++;
        this.parseValue(entries, path ? path + '.' + key : key);
        this.skipWs();
        if (this.s[this.pos] === ',') { this.pos++; continue; }
        if (this.s[this.pos] === '}') { this.pos++; break; }
        throw new Error('expected , or } at ' + this.pos);
      }
      if (Object.keys(entries).length === 0) f[path || ''] = ['obj', '{}'];
      else Object.assign(f, entries);
      return;
    }
    if (c === '[') {
      this.pos++;
      const n = [];
      for (;;) {
        this.skipWs();
        if (this.s[this.pos] === ']') { this.pos++; break; }
        const entries = {};
        this.parseValue(entries, path + '[0]');
        // parseValue 把值写到 entries 的某个键下（path 以 [0] 结尾，实际键即 path+'[0]' 或嵌套）
        // 数组元素统一以索引路径收集：用单键容器承接
        n.push(entries);
        this.skipWs();
        if (this.s[this.pos] === ',') { this.pos++; continue; }
        if (this.s[this.pos] === ']') { this.pos++; break; }
        throw new Error('expected , or ] at ' + this.pos);
      }
      // 重建索引路径：每个元素的 entries 键形如 <prefix>[0]...，需按实际索引替换 [0]
      if (n.length === 0) {
        if (path) f[path] = ['arr', '[]'];
        return;
      }
      n.forEach((entries, idx) => {
        for (const k of Object.keys(entries)) {
          // 只替换首现 [0]（元素自身索引槽），内层数组的 [0] 保持
          const fixed = k.replace(/\[0\]/, `[${idx}]`);
          f[fixed] = entries[k];
        }
      });
      return;
    }
    if (c === '"') { f[path] = ['str', this.parseString()]; return; }
    if (this.s.startsWith('true', this.pos)) { this.pos += 4; f[path] = ['bool', true]; return; }
    if (this.s.startsWith('false', this.pos)) { this.pos += 5; f[path] = ['bool', false]; return; }
    if (this.s.startsWith('null', this.pos)) { this.pos += 4; f[path] = ['null', null]; return; }
    this.parseNumber(f, path);
  }
}

function project(inPath, outPath) {
  const lines = fs.readFileSync(inPath, 'utf8').split('\n');
  const out = [];
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    const sc = new Scanner(line);
    const f = {};
    sc.parseValue(f, '');
    out.push(JSON.stringify({ i, f }));
  }
  fs.writeFileSync(outPath, out.join('\n') + '\n', 'utf8');
}

function emit(inPath, outPath) {
  const lines = fs.readFileSync(inPath, 'utf8').split('\n');
  const out = [];
  for (const line of lines) {
    if (!line.trim()) continue;
    out.push(JSON.stringify(JSON.parse(line)));
  }
  fs.writeFileSync(outPath, out.join('\n') + '\n', 'utf8');
}

const [mode, inPath, outPath] = process.argv.slice(2);
if (mode === 'project') project(inPath, outPath);
else if (mode === 'emit') emit(inPath, outPath);
else { console.error('unknown mode: ' + mode); process.exit(2); }
