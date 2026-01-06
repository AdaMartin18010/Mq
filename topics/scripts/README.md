# 部署和测试脚本

## 目录

- [部署和测试脚本](#部署和测试脚本)
  - [目录](#目录)
  - [部署脚本](#部署脚本)
    - [Kafka部署](#kafka部署)
    - [NATS部署](#nats部署)
    - [RabbitMQ部署](#rabbitmq部署)
  - [测试脚本](#测试脚本)
    - [性能测试](#性能测试)
    - [故障注入测试](#故障注入测试)
  - [运维脚本](#运维脚本)
    - [健康检查](#健康检查)
    - [故障诊断](#故障诊断)
    - [性能分析](#性能分析)
    - [备份恢复](#备份恢复)
    - [清理工具](#清理工具)
    - [实时监控](#实时监控)
    - [基准测试](#基准测试)
    - [扩缩容](#扩缩容)
    - [升级](#升级)
    - [日志查看](#日志查看)
    - [状态检查](#状态检查)
    - [启动/停止/重启](#启动停止重启)
    - [集群状态](#集群状态)
    - [指标收集](#指标收集)
    - [连接测试](#连接测试)
    - [配置验证](#配置验证)
    - [安全检查](#安全检查)
    - [主题/队列管理](#主题队列管理)
    - [指标导出](#指标导出)
    - [实时监控（增强版）](#实时监控增强版)
    - [版本检查](#版本检查)
    - [全系统管理](#全系统管理)
    - [日志查看1](#日志查看1)
    - [指标对比](#指标对比)
    - [告警检查](#告警检查)
    - [数据清理](#数据清理)
    - [性能报告](#性能报告)
    - [安全审计](#安全审计)
    - [容量检查](#容量检查)
    - [快速启动/停止](#快速启动停止)
    - [升级检查](#升级检查)
    - [综合诊断](#综合诊断)
    - [故障排查](#故障排查)
    - [资源使用](#资源使用)
    - [快速重启](#快速重启)
    - [性能调优](#性能调优)
    - [备份验证](#备份验证)
    - [健康评分](#健康评分)
    - [自动恢复](#自动恢复)
    - [通知](#通知)
    - [每日报告](#每日报告)
    - [成本分析](#成本分析)
    - [压缩测试](#压缩测试)
    - [日志清理](#日志清理)
    - [重试测试](#重试测试)
    - [安全扫描](#安全扫描)
    - [备份调度](#备份调度)
    - [死信队列监控](#死信队列监控)
    - [合规性检查](#合规性检查)
    - [性能基准测试（增强版）](#性能基准测试增强版)
    - [消息过滤测试](#消息过滤测试)
    - [数据治理检查](#数据治理检查)
    - [健康仪表板](#健康仪表板)
    - [消息优先级测试](#消息优先级测试)
    - [文档完整性检查](#文档完整性检查)
    - [系统信息收集](#系统信息收集)
    - [消息批处理测试](#消息批处理测试)
    - [知识库完整性检查](#知识库完整性检查)
    - [快速项目摘要](#快速项目摘要)
    - [消息事务测试](#消息事务测试)
    - [CI/CD配置检查](#cicd配置检查)
    - [版本信息收集](#版本信息收集)
    - [消息流控测试](#消息流控测试)
    - [多租户配置检查](#多租户配置检查)
    - [消息追踪测试](#消息追踪测试)
    - [追踪配置检查](#追踪配置检查)
    - [消息延迟测试](#消息延迟测试)
    - [延迟配置检查](#延迟配置检查)
    - [消息幂等性测试](#消息幂等性测试)
    - [幂等性配置检查](#幂等性配置检查)
    - [消息序列化测试](#消息序列化测试)
    - [Schema版本检查](#schema版本检查)
    - [消息分区测试](#消息分区测试)
    - [分区配置检查](#分区配置检查)
    - [存储配置检查](#存储配置检查)
    - [存储备份](#存储备份)
    - [监控设置](#监控设置)
    - [监控状态检查](#监控状态检查)
    - [安全审计增强版](#安全审计增强版)
    - [快速参考](#快速参考)
    - [消息路由测试](#消息路由测试)
    - [消息聚合测试](#消息聚合测试)
    - [消息转换测试](#消息转换测试)
    - [消息桥接测试](#消息桥接测试)
    - [版本兼容性检查](#版本兼容性检查)
    - [缓存优化](#缓存优化)
    - [限流检查](#限流检查)
    - [降级检查](#降级检查)
    - [监控告警检查](#监控告警检查)
    - [性能调优](#性能调优-1)
    - [容量规划](#容量规划)
    - [灾难恢复检查](#灾难恢复检查)
    - [消息测试](#消息测试)
    - [成本优化](#成本优化)
    - [自动化运维检查](#自动化运维检查)
  - [使用说明](#使用说明)
    - [权限设置](#权限设置)
    - [执行脚本](#执行脚本)

---

## 部署脚本

### Kafka部署

- **文件**: `deploy-kafka.sh`
- **用法**: `./deploy-kafka.sh [kraft]`
- **说明**: 快速部署Kafka，支持传统模式和KRaft模式

### NATS部署

- **文件**: `deploy-nats.sh`
- **用法**: `./deploy-nats.sh`
- **说明**: 快速部署NATS Server

### RabbitMQ部署

- **文件**: `deploy-rabbitmq.sh`
- **用法**: `./deploy-rabbitmq.sh`
- **说明**: 使用Docker快速部署RabbitMQ

---

## 测试脚本

### 性能测试

- **文件**: `performance-test.sh`
- **用法**: `./performance-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息队列性能

### 故障注入测试

- **文件**: `chaos-test.sh`
- **用法**: `./chaos-test.sh [kafka|nats|rabbitmq] [network|partition|disk]`
- **说明**: 故障注入测试（混沌工程）

## 运维脚本

### 健康检查

- **文件**: `health-check.sh`
- **用法**: `./health-check.sh [kafka|nats|rabbitmq|redis|all]`
- **说明**: 检查消息队列健康状态

### 故障诊断

- **文件**: `diagnose.sh`
- **用法**: `./diagnose.sh [kafka|nats|rabbitmq|all]`
- **说明**: 诊断消息队列故障

### 性能分析

- **文件**: `performance-analyze.sh`
- **用法**: `./performance-analyze.sh [kafka|nats|rabbitmq|all]`
- **说明**: 分析消息队列性能指标

### 备份恢复

- **文件**: `backup-restore.sh`
- **用法**:
  - 备份: `./backup-restore.sh backup [kafka|rabbitmq]`
  - 恢复: `./backup-restore.sh restore [kafka|rabbitmq] [backup_file]`
- **说明**: 备份和恢复消息队列数据

### 清理工具

- **文件**: `cleanup.sh`
- **用法**: `./cleanup.sh [kafka|nats|rabbitmq|all] [logs|topics]`
- **说明**: 清理日志文件和旧数据

### 实时监控

- **文件**: `monitor.sh`
- **用法**: `./monitor.sh [kafka|nats|rabbitmq]`
- **说明**: 实时监控消息队列状态（每5秒刷新）

### 基准测试

- **文件**: `benchmark.sh`
- **用法**: `./benchmark.sh [kafka|nats|rabbitmq] [duration] [rate]`
- **说明**: 运行基准测试（可配置时长和速率）

### 扩缩容

- **文件**: `scale.sh`
- **用法**: `./scale.sh [kafka|nats|rabbitmq] [scale-up|scale-down] [count]`
- **说明**: 扩缩容消息队列集群

### 升级

- **文件**: `update.sh`
- **用法**: `./update.sh [kafka|nats|rabbitmq] [version]`
- **说明**: 升级消息队列到指定版本

### 日志查看

- **文件**: `logs.sh`
- **用法**: `./logs.sh [kafka|nats|rabbitmq] [lines]`
- **说明**: 查看消息队列日志（默认100行）

### 状态检查

- **文件**: `status.sh`
- **用法**: `./status.sh [kafka|nats|rabbitmq|redis|all]`
- **说明**: 快速检查消息队列运行状态

### 启动/停止/重启

- **文件**: `start.sh` / `stop.sh` / `restart.sh`
- **用法**: `./start.sh [kafka|nats|rabbitmq|redis|all]`
- **说明**: 启动、停止或重启消息队列服务

### 集群状态

- **文件**: `cluster-status.sh`
- **用法**: `./cluster-status.sh [kafka|nats|rabbitmq|all]`
- **说明**: 检查消息队列集群状态

### 指标收集

- **文件**: `metrics.sh`
- **用法**: `./metrics.sh [kafka|nats|rabbitmq|all]`
- **说明**: 收集消息队列性能指标

### 连接测试

- **文件**: `test-connection.sh`
- **用法**: `./test-connection.sh [kafka|nats|rabbitmq|redis|all]`
- **说明**: 测试消息队列连接状态

### 配置验证

- **文件**: `validate-config.sh`
- **用法**: `./validate-config.sh [kafka|nats|rabbitmq] [config_file]`
- **说明**: 验证消息队列配置文件

### 安全检查

- **文件**: `security-check.sh`
- **用法**: `./security-check.sh [kafka|nats|rabbitmq|all]`
- **说明**: 检查消息队列安全配置（TLS/SSL、认证、授权）

### 主题/队列管理

- **文件**: `topics-list.sh` / `clean-topics.sh`
- **用法**:
  - 列表: `./topics-list.sh [kafka|nats|rabbitmq|redis|all]`
  - 清理: `./clean-topics.sh [kafka|rabbitmq|redis] [pattern]`
- **说明**: 列出或清理消息队列主题/队列

### 指标导出

- **文件**: `export-metrics.sh`
- **用法**: `./export-metrics.sh [kafka|nats|rabbitmq] [output_file]`
- **说明**: 导出消息队列指标到文件

### 实时监控（增强版）

- **文件**: `watch.sh`
- **用法**: `./watch.sh [kafka|nats|rabbitmq] [interval]`
- **说明**: 实时监控消息队列状态（可配置刷新间隔）

### 版本检查

- **文件**: `version.sh`
- **用法**: `./version.sh [kafka|nats|rabbitmq|redis|all]`
- **说明**: 检查消息队列版本信息

### 全系统管理

- **文件**: `health-check-all.sh` / `backup-all.sh` / `restore-all.sh` / `benchmark-all.sh`
- **用法**:
  - 健康检查: `./health-check-all.sh`
  - 备份: `./backup-all.sh [backup_dir]`
  - 恢复: `./restore-all.sh <backup_dir>`
  - 基准测试: `./benchmark-all.sh [duration] [message_size] [message_rate]`
- **说明**: 对所有消息队列系统进行统一管理

### 日志查看1

- **文件**: `logs-tail.sh`
- **用法**: `./logs-tail.sh [kafka|nats|rabbitmq] [lines]`
- **说明**: 实时查看消息队列日志

### 指标对比

- **文件**: `metrics-compare.sh`
- **用法**: `./metrics-compare.sh [output_file]`
- **说明**: 对比所有消息队列系统的指标

### 告警检查

- **文件**: `alerts-check.sh`
- **用法**: `./alerts-check.sh [kafka|nats|rabbitmq|all]`
- **说明**: 检查消息队列系统告警状态

### 数据清理

- **文件**: `cleanup-old-data.sh`
- **用法**: `./cleanup-old-data.sh [kafka|nats|rabbitmq] [retention_days]`
- **说明**: 清理旧数据（设置保留策略）

### 性能报告

- **文件**: `performance-report.sh`
- **用法**: `./performance-report.sh [kafka|nats|rabbitmq|all] [output_file]`
- **说明**: 生成性能报告

### 安全审计

- **文件**: `security-audit.sh`
- **用法**: `./security-audit.sh [kafka|nats|rabbitmq|all] [output_file]`
- **说明**: 执行安全审计并生成报告

### 容量检查

- **文件**: `capacity-check.sh`
- **用法**: `./capacity-check.sh [kafka|nats|rabbitmq|all]`
- **说明**: 检查消息队列系统容量使用情况

### 快速启动/停止

- **文件**: `quick-start.sh` / `quick-stop.sh`
- **用法**:
  - 启动: `./quick-start.sh`
  - 停止: `./quick-stop.sh`
- **说明**: 一键启动/停止所有消息队列系统

### 升级检查

- **文件**: `upgrade-check.sh`
- **用法**: `./upgrade-check.sh [kafka|nats|rabbitmq|all]`
- **说明**: 检查当前版本并提供升级建议

### 综合诊断

- **文件**: `diagnostics.sh`
- **用法**: `./diagnostics.sh [kafka|nats|rabbitmq|all] [output_file]`
- **说明**: 执行综合诊断并生成报告

### 故障排查

- **文件**: `troubleshoot.sh`
- **用法**: `./troubleshoot.sh [kafka|nats|rabbitmq|all] [issue_type]`
- **说明**: 执行故障排查

### 资源使用

- **文件**: `resource-usage.sh`
- **用法**: `./resource-usage.sh [kafka|nats|rabbitmq|all]`
- **说明**: 检查消息队列系统资源使用情况

### 快速重启

- **文件**: `quick-restart.sh`
- **用法**: `./quick-restart.sh`
- **说明**: 一键重启所有消息队列系统

### 性能调优

- **文件**: `performance-tune.sh`
- **用法**: `./performance-tune.sh [kafka|nats|rabbitmq|all]`
- **说明**: 提供性能调优建议

### 备份验证

- **文件**: `backup-verify.sh`
- **用法**: `./backup-verify.sh <backup_directory>`
- **说明**: 验证备份文件完整性

### 健康评分

- **文件**: `health-score.sh`
- **用法**: `./health-score.sh [kafka|nats|rabbitmq|all]`
- **说明**: 计算消息队列系统健康评分

### 自动恢复

- **文件**: `auto-recovery.sh`
- **用法**: `./auto-recovery.sh [kafka|nats|rabbitmq|all] [max_retries]`
- **说明**: 自动检测故障并尝试恢复

### 通知

- **文件**: `notify.sh`
- **用法**: `./notify.sh [message] [level]`
- **说明**: 发送通知（支持邮件/钉钉/企业微信）

### 每日报告

- **文件**: `daily-report.sh`
- **用法**: `./daily-report.sh [output_file]`
- **说明**: 生成每日运维报告

### 成本分析

- **文件**: `cost-analysis.sh`
- **用法**: `./cost-analysis.sh [output_file]`
- **说明**: 分析消息队列系统成本

### 压缩测试

- **文件**: `compress-test.sh`
- **用法**: `./compress-test.sh [message_size_kb] [message_count]`
- **说明**: 测试压缩算法性能

### 日志清理

- **文件**: `cleanup-logs.sh`
- **用法**: `./cleanup-logs.sh [kafka|nats|rabbitmq|all] [retention_days]`
- **说明**: 清理消息队列日志文件

### 重试测试

- **文件**: `retry-test.sh`
- **用法**: `./retry-test.sh [kafka|nats|rabbitmq] [max_retries] [retry_delay]`
- **说明**: 测试消息重试机制

### 安全扫描

- **文件**: `security-scan.sh`
- **用法**: `./security-scan.sh [kafka|nats|rabbitmq|all] [output_file]`
- **说明**: 执行安全扫描并生成报告

### 备份调度

- **文件**: `backup-schedule.sh`
- **用法**: `./backup-schedule.sh [backup_dir] [retention_days]`
- **说明**: 定时备份任务（可配置cron）

### 死信队列监控

- **文件**: `dlq-monitor.sh`
- **用法**: `./dlq-monitor.sh [kafka|nats|rabbitmq|all]`
- **说明**: 监控死信队列状态

### 合规性检查

- **文件**: `compliance-check.sh`
- **用法**: `./compliance-check.sh [gdpr|hipaa|pci|all] [output_file]`
- **说明**: 执行合规性检查并生成报告

### 性能基准测试（增强版）

- **文件**: `performance-benchmark.sh`
- **用法**: `./performance-benchmark.sh [kafka|nats|rabbitmq] [duration] [message_size] [message_rate]`
- **说明**: 执行详细的性能基准测试

### 消息过滤测试

- **文件**: `filter-test.sh`
- **用法**: `./filter-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息过滤机制

### 数据治理检查

- **文件**: `data-governance.sh`
- **用法**: `./data-governance.sh [output_file]`
- **说明**: 执行数据治理检查并生成报告

### 健康仪表板

- **文件**: `health-dashboard.sh`
- **用法**: `./health-dashboard.sh [interval]`
- **说明**: 实时显示所有消息队列系统健康状态

### 消息优先级测试

- **文件**: `priority-test.sh`
- **用法**: `./priority-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息优先级机制

### 文档完整性检查

- **文件**: `documentation-check.sh`
- **用法**: `./documentation-check.sh`
- **说明**: 检查文档完整性

### 系统信息收集

- **文件**: `system-info.sh`
- **用法**: `./system-info.sh [output_file]`
- **说明**: 收集系统信息并生成报告

### 消息批处理测试

- **文件**: `batch-test.sh`
- **用法**: `./batch-test.sh [kafka|nats|rabbitmq] [batch_size] [message_count]`
- **说明**: 测试消息批处理机制

### 知识库完整性检查

- **文件**: `knowledge-base-check.sh`
- **用法**: `./knowledge-base-check.sh`
- **说明**: 检查知识库完整性和结构

### 快速项目摘要

- **文件**: `quick-summary.sh`
- **用法**: `./quick-summary.sh`
- **说明**: 生成项目快速摘要和统计信息

### 消息事务测试

- **文件**: `transaction-test.sh`
- **用法**: `./transaction-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息事务机制

### CI/CD配置检查

- **文件**: `ci-cd-check.sh`
- **用法**: `./ci-cd-check.sh`
- **说明**: 检查CI/CD配置文件

### 版本信息收集

- **文件**: `version-info.sh`
- **用法**: `./version-info.sh [output_file]`
- **说明**: 收集消息队列系统版本信息

### 消息流控测试

- **文件**: `flow-control-test.sh`
- **用法**: `./flow-control-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息流控机制

### 多租户配置检查

- **文件**: `multi-tenant-check.sh`
- **用法**: `./multi-tenant-check.sh`
- **说明**: 检查多租户配置

### 消息追踪测试

- **文件**: `trace-test.sh`
- **用法**: `./trace-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息追踪机制

### 追踪配置检查

- **文件**: `trace-check.sh`
- **用法**: `./trace-check.sh`
- **说明**: 检查消息追踪配置

### 消息延迟测试

- **文件**: `delay-test.sh`
- **用法**: `./delay-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息延迟机制

### 延迟配置检查

- **文件**: `delay-check.sh`
- **用法**: `./delay-check.sh`
- **说明**: 检查消息延迟配置

### 消息幂等性测试

- **文件**: `idempotency-test.sh`
- **用法**: `./idempotency-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息幂等性机制

### 幂等性配置检查

- **文件**: `idempotency-check.sh`
- **用法**: `./idempotency-check.sh`
- **说明**: 检查消息幂等性配置

### 消息序列化测试

- **文件**: `serialization-test.sh`
- **用法**: `./serialization-test.sh [kafka|nats|rabbitmq] [json|avro|protobuf]`
- **说明**: 测试消息序列化机制

### Schema版本检查

- **文件**: `schema-check.sh`
- **用法**: `./schema-check.sh`
- **说明**: 检查Schema版本和Schema Registry状态

### 消息分区测试

- **文件**: `partition-test.sh`
- **用法**: `./partition-test.sh [kafka|nats|rabbitmq]`
- **说明**: 测试消息分区机制

### 分区配置检查

- **文件**: `partition-check.sh`
- **用法**: `./partition-check.sh`
- **说明**: 检查消息分区配置

### 存储配置检查

- **文件**: `storage-check.sh`
- **用法**: `./storage-check.sh`
- **说明**: 检查消息存储配置

### 存储备份

- **文件**: `storage-backup.sh`
- **用法**: `./storage-backup.sh [full|incremental|snapshot] [backup_dir]`
- **说明**: 备份消息存储数据

### 监控设置

- **文件**: `monitor-setup.sh`
- **用法**: `./monitor-setup.sh`
- **说明**: 设置消息监控（Prometheus、Grafana、Exporter）

### 监控状态检查

- **文件**: `monitor-check.sh`
- **用法**: `./monitor-check.sh`
- **说明**: 检查消息监控状态

### 安全审计增强版

- **文件**: `security-audit-enhanced.sh`
- **用法**: `./security-audit-enhanced.sh [output_file]`
- **说明**: 增强版消息安全审计脚本（生成详细安全审计报告）

### 快速参考

- **文件**: `quick-reference.sh`
- **用法**: `./quick-reference.sh [kafka|nats|rabbitmq|all]`
- **说明**: 显示常用命令和配置的快速参考

### 消息路由测试

- **文件**: `routing-test.sh`
- **用法**: `./routing-test.sh [kafka|nats|rabbitmq] [routing_type]`
- **说明**: 测试消息路由机制

### 消息聚合测试

- **文件**: `aggregation-test.sh`
- **用法**: `./aggregation-test.sh [kafka|nats|rabbitmq] [aggregation_type]`
- **说明**: 测试消息聚合机制

### 消息转换测试

- **文件**: `transform-test.sh`
- **用法**: `./transform-test.sh [kafka|nats|rabbitmq] [transform_type]`
- **说明**: 测试消息转换机制

### 消息桥接测试

- **文件**: `bridge-test.sh`
- **用法**: `./bridge-test.sh [kafka-rabbitmq|nats-kafka|rabbitmq-nats]`
- **说明**: 测试消息桥接机制

### 版本兼容性检查

- **文件**: `version-compat-check.sh`
- **用法**: `./version-compat-check.sh`
- **说明**: 检查消息版本兼容性（Schema Registry兼容性、版本管理建议）

### 缓存优化

- **文件**: `cache-optimize.sh`
- **用法**: `./cache-optimize.sh`
- **说明**: 消息缓存优化（缓存配置检查、性能检查、一致性检查）

### 限流检查

- **文件**: `rate-limit-check.sh`
- **用法**: `./rate-limit-check.sh`
- **说明**: 消息限流检查（Producer/Consumer限流配置、限流策略检查）

### 降级检查

- **文件**: `degrade-check.sh`
- **用法**: `./degrade-check.sh`
- **说明**: 消息降级检查（降级策略、熔断器配置、降级处理检查）

### 监控告警检查

- **文件**: `monitor-alert-check.sh`
- **用法**: `./monitor-alert-check.sh`
- **说明**: 消息监控告警检查（监控系统、Exporter、告警规则检查）

### 性能调优

- **文件**: `performance-tune.sh`
- **用法**: `./performance-tune.sh`
- **说明**: 消息性能调优（Producer/Consumer/系统性能调优检查）

### 容量规划

- **文件**: `capacity-plan.sh`
- **用法**: `./capacity-plan.sh`
- **说明**: 消息容量规划（存储/计算/扩展容量计算）

### 灾难恢复检查

- **文件**: `disaster-recovery-check.sh`
- **用法**: `./disaster-recovery-check.sh`
- **说明**: 消息灾难恢复检查（备份策略、恢复策略、恢复测试检查）

### 消息测试

- **文件**: `message-test.sh`
- **用法**: `./message-test.sh [functional|performance|reliability|all]`
- **说明**: 消息测试（功能测试、性能测试、可靠性测试）

### 成本优化

- **文件**: `cost-optimize.sh`
- **用法**: `./cost-optimize.sh`
- **说明**: 消息成本优化（资源成本、运营成本、云服务成本检查）

### 自动化运维检查

- **文件**: `automation-check.sh`
- **用法**: `./automation-check.sh`
- **说明**: 消息自动化运维检查（部署自动化、监控自动化、运维自动化检查）

### 数据治理检查

- **文件**: `data-governance-check.sh`
- **用法**: `./data-governance-check.sh`
- **说明**: 消息数据治理检查（Schema管理、数据质量、数据生命周期管理检查）

---

## 使用说明

### 权限设置

```bash
chmod +x *.sh
```

### 执行脚本

```bash
./deploy-kafka.sh
./deploy-nats.sh
./performance-test.sh kafka
```

---

**最后更新**: 2025-12-31
