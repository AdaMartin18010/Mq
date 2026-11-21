// 跨语言金样本投影客户端（Go，批次189）
// 用法:
//   go run project_emit.go project <in.jsonl> <out.jsonl>   精确字面量投影（UseNumber）
//   go run project_emit.go emit    <in.jsonl> <out.jsonl>   默认编码器再序列化（float64 语义）
// 构建: go build -o project_emit project_emit.go
package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"
)

// numTag: UseNumber 解码后的数字 = json.Number（字面量字符串）
func flatten(v interface{}, path string, f map[string]interface{}) {
	switch t := v.(type) {
	case map[string]interface{}:
		if len(t) == 0 {
			if path != "" {
				f[path] = []interface{}{"obj", "{}"}
			} else {
				f[""] = []interface{}{"obj", "{}"}
			}
			return
		}
		for k, vv := range t {
			p := k
			if path != "" {
				p = path + "." + k
			}
			flatten(vv, p, f)
		}
	case []interface{}:
		if len(t) == 0 {
			f[path] = []interface{}{"arr", "[]"}
			return
		}
		for i, vv := range t {
			flatten(vv, fmt.Sprintf("%s[%d]", path, i), f)
		}
	case json.Number:
		// 语义值: 整数字面量 → 精确十进制；浮点字面量 → float64 最短十进制
		sem := ""
		if iv, err := t.Int64(); err == nil {
			sem = strconv.FormatInt(iv, 10)
		} else if fv, err := t.Float64(); err == nil {
			sem = strconv.FormatFloat(fv, 'g', -1, 64)
		} else {
			sem = t.String()
		}
		f[path] = []interface{}{"num", t.String(), sem}
	case string:
		f[path] = []interface{}{"str", t}
	case bool:
		f[path] = []interface{}{"bool", t}
	case nil:
		f[path] = []interface{}{"null", nil}
	default:
		panic(fmt.Sprintf("unexpected type %T at %s", v, path))
	}
}

func main() {
	if len(os.Args) != 4 {
		fmt.Fprintln(os.Stderr, "usage: project_emit <project|emit> <in.jsonl> <out.jsonl>")
		os.Exit(2)
	}
	mode, inPath, outPath := os.Args[1], os.Args[2], os.Args[3]
	in, err := os.Open(inPath)
	if err != nil {
		panic(err)
	}
	defer in.Close()
	out, err := os.Create(outPath)
	if err != nil {
		panic(err)
	}
	defer out.Close()
	enc := json.NewEncoder(out)
	enc.SetEscapeHTML(false)

	sc := bufio.NewScanner(in)
	sc.Buffer(make([]byte, 1024*1024), 1024*1024)
	i := 0
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		if line == "" {
			continue
		}
		var v interface{}
		switch mode {
		case "project":
			dec := json.NewDecoder(strings.NewReader(line))
			dec.UseNumber()
			if err := dec.Decode(&v); err != nil {
				panic(fmt.Sprintf("line %d: %v", i, err))
			}
			f := map[string]interface{}{}
			flatten(v, "", f)
			if err := enc.Encode(map[string]interface{}{"i": i, "f": f}); err != nil {
				panic(err)
			}
		case "emit":
			if err := json.Unmarshal([]byte(line), &v); err != nil {
				panic(fmt.Sprintf("line %d: %v", i, err))
			}
			b, err := json.Marshal(v)
			if err != nil {
				panic(err)
			}
			out.Write(append(b, '\n'))
		default:
			fmt.Fprintln(os.Stderr, "unknown mode: "+mode)
			os.Exit(2)
		}
		i++
	}
	if err := sc.Err(); err != nil {
		panic(err)
	}
}
