package com.example.mq;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.MessageProperties;
import java.io.IOException;
import java.util.concurrent.TimeoutException;

public class RabbitMQProducer {
    private static final String EXCHANGE_NAME = "order_exchange";
    private static final String ROUTING_KEY = "order.created";
    private static final String QUEUE_NAME = "order_queue";

    public static void main(String[] args) throws IOException, TimeoutException {
        // 创建连接工厂
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("localhost");
        factory.setPort(5672);
        factory.setUsername("guest");
        factory.setPassword("guest");

        // 创建连接和通道
        try (Connection connection = factory.newConnection();
             Channel channel = connection.createChannel()) {

            // 声明Exchange
            channel.exchangeDeclare(EXCHANGE_NAME, "direct", true);

            // 声明队列
            channel.queueDeclare(QUEUE_NAME, true, false, false, null);

            // 绑定队列到Exchange
            channel.queueBind(QUEUE_NAME, EXCHANGE_NAME, ROUTING_KEY);

            // 发送消息
            for (int i = 0; i < 10; i++) {
                String message = String.format(
                    "{\"order_id\":\"ORD-%04d\",\"user_id\":\"USER-%d\",\"amount\":%.2f}",
                    i, i, 100.0 + i
                );

                channel.basicPublish(
                    EXCHANGE_NAME,
                    ROUTING_KEY,
                    MessageProperties.PERSISTENT_TEXT_PLAIN,
                    message.getBytes("UTF-8")
                );

                System.out.println("Sent: ORD-" + String.format("%04d", i));
            }
        }

        System.out.println("Messages sent successfully");
    }
}
