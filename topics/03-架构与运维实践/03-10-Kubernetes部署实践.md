# 3.10 Kubernetes部署实践

## 目录

- [3.10 Kubernetes部署实践](#310-kubernetes部署实践)
  - [目录](#目录)
  - [3.10.1 Kafka Operator部署](#3101-kafka-operator部署)
  - [3.10.2 NATS Operator部署](#3102-nats-operator部署)
  - [3.10.3 MQTT Broker部署](#3103-mqtt-broker部署)
  - [3.10.4 Pulsar Operator部署](#3104-pulsar-operator部署)
  - [3.10.5 Service Mesh集成](#3105-service-mesh集成)
  - [3.10.6 云原生监控](#3106-云原生监控)
  - [3.10.7 参考资源](#3107-参考资源)

---

## 3.10.1 Kafka Operator部署

**Strimzi Kafka Operator**是Kubernetes上部署Kafka的推荐方案。

**部署步骤**：

```bash
# 安装Strimzi Operator
kubectl create namespace kafka
kubectl apply -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

# 部署Kafka集群
kubectl apply -f - <<EOF
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
  namespace: kafka
spec:
  kafka:
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
      - name: tls
        port: 9093
        type: internal
        tls: true
    storage:
      type: persistent-claim
      size: 100Gi
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 20Gi
EOF
```

**参考**: [Strimzi Kafka Operator](https://strimzi.io/)

---

## 3.10.2 NATS Operator部署

**NATS Operator**简化NATS在Kubernetes上的部署。

**部署步骤**：

```bash
# 安装NATS Operator
kubectl apply -f https://github.com/nats-io/nats-operator/releases/download/v0.8.0/00-prereqs.yaml
kubectl apply -f https://github.com/nats-io/nats-operator/releases/download/v0.8.0/10-deployment.yaml

# 部署NATS集群
kubectl apply -f - <<EOF
apiVersion: nats.io/v1alpha2
kind: NatsCluster
metadata:
  name: nats-cluster
spec:
  size: 3
  version: "2.9.0"
EOF
```

---

## 3.10.3 MQTT Broker部署

**EMQX Kubernetes部署**：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: emqx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: emqx
  template:
    metadata:
      labels:
        app: emqx
    spec:
      containers:
      - name: emqx
        image: emqx/emqx:5.0.0
        ports:
        - containerPort: 1883
        - containerPort: 8883
        - containerPort: 8083
        env:
        - name: EMQX_NAME
          value: emqx
        - name: EMQX_CLUSTER__DISCOVERY_STRATEGY
          value: k8s
```

---

## 3.10.4 Pulsar Operator部署

**Pulsar Operator部署**：

```bash
# 安装Pulsar Operator
kubectl apply -f https://raw.githubusercontent.com/apache/pulsar-operator/master/deploy/crds/pulsar.apache.org_pulsarclusters_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/apache/pulsar-operator/master/deploy/operator.yaml

# 部署Pulsar集群
kubectl apply -f - <<EOF
apiVersion: pulsar.apache.org/v1alpha1
kind: PulsarCluster
metadata:
  name: pulsar-cluster
spec:
  zookeeper:
    replicas: 3
  bookkeeper:
    replicas: 3
  broker:
    replicas: 3
EOF
```

---

## 3.10.5 Service Mesh集成

**Istio集成示例**：

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kafka
spec:
  hosts:
  - kafka
  tcp:
  - match:
    - port: 9092
    route:
    - destination:
        host: kafka
        port:
          number: 9092
```

---

## 3.10.6 云原生监控

**Prometheus监控配置**：

```yaml
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: kafka-metrics
spec:
  selector:
    matchLabels:
      app: kafka
  endpoints:
  - port: metrics
    interval: 30s
```

---

## 3.10.7 参考资源

- [Kubernetes官方文档](https://kubernetes.io/docs/)
- [Strimzi Kafka Operator](https://strimzi.io/)
- [NATS Operator](https://github.com/nats-io/nats-operator)

---

**最后更新**: 2025-12-31
