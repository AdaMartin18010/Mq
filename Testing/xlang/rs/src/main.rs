// 跨语言金样本投影客户端（Rust，批次189）
// 依赖: serde_json（arbitrary_precision 特性，Cargo.toml 声明）
// 用法:
//   project_emit project <in.jsonl> <out.jsonl>   精确字面量投影
//   project_emit emit    <in.jsonl> <out.jsonl>   默认编码器再序列化（int 保持 / float 塌缩 f64）
// emit 说明: arbitrary_precision 下 to_string 会原样输出字面量（不塌缩），
// 为复现 serde_json 默认语义，emit 模式将数值树重建为 i64/u64/f64 后再序列化。

use serde_json::{Map, Number, Value};
use std::io::{BufRead, Write};

fn flatten(v: &Value, path: &str, out: &mut Map<String, Value>) {
    match v {
        Value::Number(n) => {
            // arbitrary_precision 下 Number 持有原始字面量字符串
            let lit = n.to_string();
            let sem = if let Some(iv) = n.as_i64() {
                iv.to_string()
            } else if let Some(ub) = n.as_u64() {
                ub.to_string()
            } else if let Some(f) = n.as_f64() {
                f.to_string()
            } else {
                lit.clone()
            };
            out.insert(
                path.to_string(),
                Value::Array(vec![Value::String("num".into()), Value::String(lit), Value::String(sem)]),
            );
        }
        Value::Object(m) => {
            if m.is_empty() {
                if !path.is_empty() {
                    out.insert(path.to_string(), Value::Array(vec![Value::String("obj".into()), Value::String("{}".into())]));
                } else {
                    out.insert(String::new(), Value::Array(vec![Value::String("obj".into()), Value::String("{}".into())]));
                }
                return;
            }
            for (k, vv) in m {
                let p = if path.is_empty() { k.clone() } else { format!("{}.{}", path, k) };
                flatten(vv, &p, out);
            }
        }
        Value::Array(a) => {
            if a.is_empty() {
                out.insert(path.to_string(), Value::Array(vec![Value::String("arr".into()), Value::String("[]".into())]));
                return;
            }
            for (i, vv) in a.iter().enumerate() {
                flatten(vv, &format!("{}[{}]", path, i), out);
            }
        }
        Value::String(s) => {
            out.insert(path.to_string(), Value::Array(vec![Value::String("str".into()), Value::String(s.clone())]));
        }
        Value::Bool(b) => {
            out.insert(path.to_string(), Value::Array(vec![Value::String("bool".into()), Value::Bool(*b)]));
        }
        Value::Null => {
            out.insert(path.to_string(), Value::Array(vec![Value::String("null".into()), Value::Null]));
        }
    }
}

// 重建数值语义: int 字面量 → i64/u64；float 字面量 → f64（复现默认 serde_json 数值类型）
fn rebuild_num(v: &Value) -> Value {
    match v {
        Value::Number(n) => {
            if let Some(iv) = n.as_i64() {
                Value::Number(Number::from(iv))
            } else if let Some(ub) = n.as_u64() {
                Value::Number(Number::from(ub))
            } else if let Some(f) = n.as_f64() {
                match Number::from_f64(f) {
                    Some(n2) => Value::Number(n2),
                    None => Value::Null,
                }
            } else {
                Value::Null
            }
        }
        Value::Object(m) => Value::Object(m.iter().map(|(k, vv)| (k.clone(), rebuild_num(vv))).collect()),
        Value::Array(a) => Value::Array(a.iter().map(rebuild_num).collect()),
        other => other.clone(),
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 4 {
        eprintln!("usage: project_emit <project|emit> <in.jsonl> <out.jsonl>");
        std::process::exit(2);
    }
    let (mode, in_path, out_path) = (&args[1], &args[2], &args[3]);
    let fin = std::fs::File::open(in_path).expect("open input");
    let fout = std::fs::File::create(out_path).expect("create output");
    let reader = std::io::BufReader::new(fin);
    let mut writer = std::io::BufWriter::new(fout);
    let mut i: u64 = 0;
    for line in reader.lines() {
        let line = line.expect("read line");
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let v: Value = serde_json::from_str(line).expect("parse json");
        let out = if mode == "project" {
            let mut f = Map::new();
            flatten(&v, "", &mut f);
            let mut w = Map::new();
            w.insert("i".into(), Value::from(i));
            w.insert("f".into(), Value::Object(f));
            serde_json::to_string(&Value::Object(w)).unwrap()
        } else if mode == "emit" {
            serde_json::to_string(&rebuild_num(&v)).unwrap()
        } else {
            eprintln!("unknown mode: {}", mode);
            std::process::exit(2);
        };
        writeln!(writer, "{}", out).expect("write line");
        i += 1;
    }
}
