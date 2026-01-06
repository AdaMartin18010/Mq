#!/bin/bash
# 定时备份脚本（可配置cron）

set -e

BACKUP_DIR=${1:-"backup_$(date +%Y%m%d_%H%M%S)"}
RETENTION_DAYS=${2:-30}

echo "=== 定时备份任务 ==="
echo "备份目录: $BACKUP_DIR"
echo "保留天数: $RETENTION_DAYS"
echo ""

# 执行备份
./scripts/backup-all.sh "$BACKUP_DIR"

# 清理旧备份
echo ""
echo "清理旧备份（保留${RETENTION_DAYS}天）..."
find . -type d -name "backup_*" -mtime +$RETENTION_DAYS -exec rm -rf {} \; 2>/dev/null || true

echo ""
echo "定时备份完成！"

# Cron配置示例:
# 每天凌晨2点执行备份，保留30天
# 0 2 * * * /path/to/scripts/backup-schedule.sh /backup/dir 30
