#!/bin/bash
# 通知脚本（支持多种通知方式）

set -e

MESSAGE=${1:-"消息队列系统通知"}
LEVEL=${2:-"info"}  # info/warning/error

echo "=== 发送通知 ==="
echo "消息: $MESSAGE"
echo "级别: $LEVEL"
echo ""

# 邮件通知（需要配置）
send_email() {
    if command -v mail &> /dev/null; then
        echo "$MESSAGE" | mail -s "[$LEVEL] 消息队列通知" admin@example.com
        echo "  ✅ 邮件通知已发送"
    else
        echo "  ⚠️  邮件工具未安装"
    fi
}

# 钉钉通知（需要配置Webhook）
send_dingtalk() {
    if [ -n "$DINGTALK_WEBHOOK" ]; then
        curl -s "$DINGTALK_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"[$LEVEL] $MESSAGE\"}}" \
            &> /dev/null
        echo "  ✅ 钉钉通知已发送"
    else
        echo "  ⚠️  钉钉Webhook未配置"
    fi
}

# 企业微信通知（需要配置Webhook）
send_wechat() {
    if [ -n "$WECHAT_WEBHOOK" ]; then
        curl -s "$WECHAT_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"[$LEVEL] $MESSAGE\"}}" \
            &> /dev/null
        echo "  ✅ 企业微信通知已发送"
    else
        echo "  ⚠️  企业微信Webhook未配置"
    fi
}

# 控制台输出
echo "[$LEVEL] $MESSAGE"

# 发送通知
send_email
send_dingtalk
send_wechat

echo ""
echo "通知发送完成！"
