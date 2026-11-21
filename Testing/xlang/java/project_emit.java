// 跨语言金样本投影客户端（Java，批次189）
// 依赖: jackson-core（流式 API；构建: ./ensure-lib.sh 下载 jar）
// 用法:
//   java -cp <jackson-core.jar>:<dir> project_emit project <in.jsonl> <out.jsonl>   精确字面量投影
//   java -cp <jackson-core.jar>:<dir> project_emit emit    <in.jsonl> <out.jsonl>   默认编码器再序列化
// project: VALUE_NUMBER_* 取 getText() 精确字面量；语义值 INT/LONG/BIG_INTEGER 精确十进制，FP 按 double。
// emit:   按 Jackson 默认语义再序列化——INT 按 int/long/BigInteger，FLOAT 塌缩为 double（Double.toString 格式）。
import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonToken;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class project_emit {

    // ---------- project 模式：精确字面量投影 ----------
    static Map<String, Object> parseValue(JsonParser p, String path) throws IOException {
        Map<String, Object> f = new LinkedHashMap<>();
        JsonToken t = p.currentToken();
        if (t == JsonToken.START_OBJECT) {
            while (p.nextToken() == JsonToken.FIELD_NAME) {
                String key = p.currentName();
                p.nextToken(); // 推进到值的首 token（此时仍停在 FIELD_NAME）
                String p2 = path.isEmpty() ? key : path + "." + key;
                f.putAll(parseValue(p, p2));
            }
            if (f.isEmpty()) f.put(path.isEmpty() ? "" : path, List.of("obj", "{}"));
            return f;
        }
        if (t == JsonToken.START_ARRAY) {
            List<Map<String, Object>> elems = new ArrayList<>();
            int idx = 0;
            while (p.nextToken() != JsonToken.END_ARRAY) {
                elems.add(parseValue(p, path + "[" + idx + "]"));
                idx++;
            }
            if (elems.isEmpty()) { if (!path.isEmpty()) f.put(path, List.of("arr", "[]")); return f; }
            for (int i = 0; i < elems.size(); i++) {
                for (Map.Entry<String, Object> e : elems.get(i).entrySet()) {
                    // 只替换首现 [0]（元素自身索引槽），内层数组索引保持
                    String k = e.getKey().replaceFirst("\\[0\\]", "[" + i + "]");
                    f.put(k, e.getValue());
                }
            }
            return f;
        }
        switch (t) {
            case VALUE_NUMBER_INT: {
                String lit = p.getText();
                String sem;
                switch (p.getNumberType()) {
                    case INT: sem = String.valueOf(p.getIntValue()); break;
                    case LONG: sem = String.valueOf(p.getLongValue()); break;
                    default: sem = String.valueOf(p.getBigIntegerValue());
                }
                f.put(path, List.of("num", lit, sem));
                return f;
            }
            case VALUE_NUMBER_FLOAT: {
                String lit = p.getText();
                double d = p.getDoubleValue();
                f.put(path, List.of("num", lit, Double.toString(d)));
                return f;
            }
            case VALUE_STRING:
                f.put(path, List.of("str", p.getText()));
                return f;
            case VALUE_TRUE:
                f.put(path, List.of("bool", true));
                return f;
            case VALUE_FALSE:
                f.put(path, List.of("bool", false));
                return f;
            case VALUE_NULL:
                // List.of 拒绝 null 元素（cdc-sync 墓碑字段实证 NPE）→ Arrays.asList
                f.put(path, java.util.Arrays.asList("null", (Object) null));
                return f;
            default:
                throw new IOException("unexpected token " + t + " at " + path);
        }
    }

    static String toJson(int i, Map<String, Object> f) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"i\":").append(i).append(",\"f\":");
        writeMap(sb, f);
        sb.append("}");
        return sb.toString();
    }

    static void writeMap(StringBuilder sb, Map<String, Object> m) {
        sb.append('{');
        boolean first = true;
        for (Map.Entry<String, Object> e : m.entrySet()) {
            if (!first) sb.append(',');
            first = false;
            writeStr(sb, e.getKey());
            sb.append(':');
            writeVal(sb, e.getValue());
        }
        sb.append('}');
    }

    static void writeVal(StringBuilder sb, Object v) {
        if (v instanceof List) {
            @SuppressWarnings("unchecked")
            List<Object> l = (List<Object>) v;
            sb.append('[');
            for (int j = 0; j < l.size(); j++) {
                if (j > 0) sb.append(',');
                writeVal(sb, l.get(j));
            }
            sb.append(']');
        } else if (v instanceof Boolean) {
            sb.append(v.toString());
        } else if (v == null) {
            sb.append("null");
        } else {
            writeStr(sb, v.toString());
        }
    }

    static void writeStr(StringBuilder sb, String s) {
        sb.append('"');
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else sb.append(c);
            }
        }
        sb.append('"');
    }

    // ---------- emit 模式：Jackson 默认语义再序列化 ----------
    static String emitLine(String line) throws IOException {
        JsonFactory fac = new JsonFactory();
        JsonParser p = fac.createParser(line);
        java.io.StringWriter sw = new java.io.StringWriter();
        JsonGenerator g = fac.createGenerator(sw);
        copy(p, g);
        g.close();
        p.close();
        return sw.toString();
    }

    static void copy(JsonParser p, JsonGenerator g) throws IOException {
        JsonToken t;
        while ((t = p.nextToken()) != null) {
            switch (t) {
                case START_OBJECT: g.writeStartObject(); break;
                case END_OBJECT: g.writeEndObject(); break;
                case START_ARRAY: g.writeStartArray(); break;
                case END_ARRAY: g.writeEndArray(); break;
                case FIELD_NAME: g.writeFieldName(p.currentName()); break;
                case VALUE_STRING: g.writeString(p.getText()); break;
                case VALUE_TRUE: g.writeBoolean(true); break;
                case VALUE_FALSE: g.writeBoolean(false); break;
                case VALUE_NULL: g.writeNull(); break;
                case VALUE_NUMBER_INT:
                    switch (p.getNumberType()) {
                        case INT: g.writeNumber(p.getIntValue()); break;
                        case LONG: g.writeNumber(p.getLongValue()); break;
                        default: g.writeNumber(p.getBigIntegerValue());
                    }
                    break;
                case VALUE_NUMBER_FLOAT:
                    // 默认语义: 塌缩为 double
                    g.writeNumber(p.getDoubleValue());
                    break;
                default:
                    throw new IOException("unexpected token " + t);
            }
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 3) {
            System.err.println("usage: project_emit <project|emit> <in.jsonl> <out.jsonl>");
            System.exit(2);
        }
        String mode = args[0], inPath = args[1], outPath = args[2];
        List<String> lines = Files.readAllLines(Paths.get(inPath), StandardCharsets.UTF_8);
        List<String> out = new ArrayList<>();
        int i = 0;
        for (String line : lines) {
            if (line.trim().isEmpty()) continue;
            if (mode.equals("emit")) {
                out.add(emitLine(line));
            } else if (mode.equals("project")) {
                JsonParser p = new JsonFactory().createParser(line);
                p.nextToken(); // 推进到首 token（解析器初始无 currentToken）
                Map<String, Object> f = parseValue(p, "");
                p.close();
                out.add(toJson(i, f));
            } else {
                System.err.println("unknown mode: " + mode);
                System.exit(2);
            }
            i++;
        }
        Files.writeString(Paths.get(outPath), String.join("\n", out) + "\n", StandardCharsets.UTF_8);
    }
}
