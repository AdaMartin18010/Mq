package com.example.mq;

import com.rabbitmq.client.*;
import java.io.IOException;
import java.util.concurrent.TimeoutException;

public class RabbitMQConsumer {
    private static final String QUEUE_NAME = "order_queue";

    public static void main(String[] args) throws IOException, TimeoutException {
        // 创建连接工厂
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("localhost");
        factory.setPort(5672);
        factory.setUsername("guest");
        factory.setPassword("guest");

        // 创建连接和通道
        Connection connection = factory.newConnection();
        Channel channel = connection.createChannel();

        // 声明队列
        channel.queueDeclare(QUEUE_NAME, true, false, false, null);

        // 设置预取数量（公平分发）
        channel.basicQos(1);

        // 创建消费者
        DeliverCallback deliverCallback = (consumerTag, delivery) -> {
            String message = new String(delivery.getBody(), "UTF-8");
            System.out.println("Received: " + message);

            try {
                // 处理消息
                // processOrder(message);
            } finally {
                // 手动确认消息
                channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);
            }
        };

        // 开始消费
        channel.basicConsume(QUEUE_NAME, false, deliverCallback, consumerTag -> {});

        System.out.println("Waiting for messages. To exit press CTRL+C");
    }
}
