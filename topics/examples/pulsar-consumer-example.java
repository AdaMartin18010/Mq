import org.apache.pulsar.client.api.*;

/**
 * Pulsar Consumer示例
 * 
 * 功能：
 * - 创建Consumer并消费消息
 * - 支持多种订阅模式（Exclusive/Shared/Failover/Key_Shared）
 * - 支持消息确认
 * - 支持批量确认
 */
public class PulsarConsumerExample {
    private static final String SERVICE_URL = "pulsar://localhost:6650";
    private static final String TOPIC = "persistent://public/default/my-topic";
    private static final String SUBSCRIPTION_NAME = "my-subscription";
    
    public static void main(String[] args) throws Exception {
        // 创建Pulsar客户端
        PulsarClient client = PulsarClient.builder()
            .serviceUrl(SERVICE_URL)
            .build();
        
        try {
            // 创建Consumer（Exclusive订阅模式）
            Consumer<byte[]> consumer = client.newConsumer()
                .topic(TOPIC)
                .subscriptionName(SUBSCRIPTION_NAME)
                .subscriptionType(SubscriptionType.Shared) // Shared订阅模式
                .ackTimeout(30, TimeUnit.SECONDS)
                .subscribe();
            
            // 接收消息
            while (true) {
                Message<byte[]> msg = consumer.receive();
                
                try {
                    // 处理消息
                    String content = new String(msg.getData());
                    System.out.println("Received message: " + content);
                    System.out.println("Message ID: " + msg.getMessageId());
                    System.out.println("Message Key: " + msg.getKey());
                    System.out.println("Properties: " + msg.getProperties());
                    
                    // 确认消息
                    consumer.acknowledge(msg);
                } catch (Exception e) {
                    // 消息处理失败，否定确认
                    consumer.negativeAcknowledge(msg);
                }
            }
            
            // 关闭Consumer
            // consumer.close();
        } finally {
            // 关闭客户端
            client.close();
        }
    }
    
    /**
     * 使用消息监听器消费消息
     */
    public static void consumeWithListener() throws Exception {
        PulsarClient client = PulsarClient.builder()
            .serviceUrl(SERVICE_URL)
            .build();
        
        try {
            Consumer<byte[]> consumer = client.newConsumer()
                .topic(TOPIC)
                .subscriptionName(SUBSCRIPTION_NAME)
                .subscriptionType(SubscriptionType.Shared)
                .messageListener((consumer1, msg) -> {
                    try {
                        String content = new String(msg.getData());
                        System.out.println("Received: " + content);
                        consumer1.acknowledge(msg);
                    } catch (Exception e) {
                        consumer1.negativeAcknowledge(msg);
                    }
                })
                .subscribe();
            
            // 保持运行
            Thread.sleep(60000);
            
            consumer.close();
        } finally {
            client.close();
        }
    }
}
