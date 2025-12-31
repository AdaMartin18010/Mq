import org.apache.pulsar.client.api.*;

/**
 * Pulsar Producer示例
 * 
 * 功能：
 * - 创建Producer并发送消息
 * - 支持同步和异步发送
 * - 支持批量发送
 * - 支持事务发送
 */
public class PulsarProducerExample {
    private static final String SERVICE_URL = "pulsar://localhost:6650";
    private static final String TOPIC = "persistent://public/default/my-topic";
    
    public static void main(String[] args) throws Exception {
        // 创建Pulsar客户端
        PulsarClient client = PulsarClient.builder()
            .serviceUrl(SERVICE_URL)
            .build();
        
        try {
            // 创建Producer
            Producer<byte[]> producer = client.newProducer()
                .topic(TOPIC)
                .producerName("my-producer")
                .enableBatching(true)
                .batchingMaxMessages(100)
                .batchingMaxPublishDelay(10, TimeUnit.MILLISECONDS)
                .create();
            
            // 同步发送消息
            MessageId msgId = producer.send("Hello Pulsar".getBytes());
            System.out.println("Message sent: " + msgId);
            
            // 异步发送消息
            producer.sendAsync("Hello Pulsar Async".getBytes())
                .thenAccept(msgId -> {
                    System.out.println("Message sent async: " + msgId);
                });
            
            // 发送带属性的消息
            producer.newMessage()
                .key("my-key")
                .value("Hello Pulsar with Key".getBytes())
                .property("property1", "value1")
                .send();
            
            // 事务发送（需要启用事务）
            /*
            Transaction txn = client.newTransaction()
                .withTransactionTimeout(30, TimeUnit.SECONDS)
                .build()
                .get();
            
            producer.newMessage(txn)
                .value("Transaction Message".getBytes())
                .send();
            
            txn.commit().get();
            */
            
            // 关闭Producer
            producer.close();
        } finally {
            // 关闭客户端
            client.close();
        }
    }
}
