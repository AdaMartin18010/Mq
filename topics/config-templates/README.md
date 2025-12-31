# 配置模板库

## 目录

- [配置模板库](#配置模板库)
  - [目录](#目录)
  - [Kafka配置模板](#kafka配置模板)
  - [MQTT配置模板](#mqtt配置模板)
  - [NATS配置模板](#nats配置模板)
  - [使用说明](#使用说明)

---

## Kafka配置模板

### Server配置
- **文件**: [kafka-server.properties.template](./kafka-server.properties.template)
- **用途**: Kafka Broker服务器配置
- **关键配置项**:
  - Broker ID和监听地址
  - 日志目录和保留策略
  - 副本和ISR配置
  - 性能调优参数
  - 安全配置
- **参考文档**:
  - [03-01-部署架构模式矩阵](../03-架构与运维实践/03-01-部署架构模式矩阵.md)
  - [01-06-架构设计深度分析](../01-基础概念与对比分析/01-06-架构设计深度分析.md)

### Producer配置
参考代码示例中的Producer配置：
- [kafka-producer-example.java](../examples/kafka-producer-example.java)

### Consumer配置
参考代码示例中的Consumer配置：
- [kafka-consumer-example.java](../examples/kafka-consumer-example.java)

## MQTT配置模板

### Broker配置
MQTT Broker配置因实现而异，常见配置项包括：
- 监听端口和协议
- 最大连接数
- 会话存储配置
- QoS配置
- 主题权限配置

**推荐Broker**:
- EMQX: [官方文档](https://www.emqx.io/docs)
- Eclipse Mosquitto: [官方文档](https://mosquitto.org/man/mosquitto-conf-5.html)
- HiveMQ: [官方文档](https://www.hivemq.com/docs/)

## NATS配置模板

### Server配置
- **文件**: [nats-server.conf.template](./nats-server.conf.template)
- **用途**: NATS Server服务器配置
- **关键配置项**:
  - 监听端口和HTTP监控端口
  - 集群配置（cluster.routes）
  - JetStream配置（存储目录、资源限制）
  - 连接和资源限制
  - TLS和认证配置
- **参考文档**:
  - [03-01-部署架构模式矩阵](../03-架构与运维实践/03-01-部署架构模式矩阵.md)
  - [01-06-架构设计深度分析](../01-基础概念与对比分析/01-06-架构设计深度分析.md)

## 使用说明

### 配置步骤

1. **复制模板**: 复制相应的配置模板文件
2. **修改配置**: 根据实际环境修改配置项
3. **验证配置**: 使用配置验证工具检查配置正确性
4. **测试部署**: 在测试环境验证配置
5. **生产部署**: 确认无误后部署到生产环境

### 配置检查清单

- [ ] Broker ID/Server名称唯一
- [ ] 监听地址和端口正确
- [ ] 日志目录有足够空间
- [ ] 副本配置合理（至少3个）
- [ ] 安全配置已启用（生产环境）
- [ ] 资源限制合理
- [ ] 监控端口已配置

### 配置优化建议

**Kafka**:
- 使用独立磁盘存储日志
- 合理设置分区数和副本数
- 启用压缩降低存储成本
- 配置JMX监控

**MQTT**:
- 合理设置最大连接数
- 配置会话存储
- 启用TLS加密
- 配置主题权限

**NATS**:
- 配置集群模式（至少3节点）
- 合理设置资源限制
- 启用JetStream（如需要）
- 配置TLS和认证

---

**参考文档**:
- [部署架构模式矩阵](../03-架构与运维实践/03-01-部署架构模式矩阵.md)
- [实践指南](../PRACTICE_GUIDE.md)
- [实施检查清单](../IMPLEMENTATION_CHECKLIST.md)
