// mq-bench: NATS / RabbitMQ producer 基准客户端（批次178/179 工具件）
// 用法:
//
//	go run . nats   -url nats://localhost:14222 -rate 10000 -dur 60 -size 1024
//	go run . rabbit -url amqp://test:test@localhost:15673 -rate 10000 -dur 60 -size 1024
//
// 口径:
//
//	nats   = 单发布者 request-reply（1KB payload, 应答方立即回 1B）, 测 RTT 与达成速率（对标 Kafka acks=all）
//	rabbit = 单发布者 paced publish + 单消费者(prefetch=10) 回读, payload 内嵌发布时间戳, 测端到端延迟
package main

import (
	"flag"
	"fmt"
	"math"
	"os"
	"sort"
	"strconv"
	"sync"
	"time"

	nats "github.com/nats-io/nats.go"
	amqp "github.com/rabbitmq/amqp091-go"
)

type params struct {
	url  string
	rate int
	dur  int
	size int
}

func pct(sorted []float64, p float64) float64 {
	if len(sorted) == 0 {
		return 0
	}
	idx := p * float64(len(sorted)-1)
	lo := int(math.Floor(idx))
	hi := int(math.Ceil(idx))
	if lo == hi {
		return sorted[lo]
	}
	frac := idx - float64(lo)
	return sorted[lo]*(1-frac) + sorted[hi]*frac
}

// paceUntil: 精确等到 next（Windows 睡眠粒度 ~1ms 粗糙 → 粗睡 + 剩余 spin 补偿）
func paceUntil(next time.Time) {
	for {
		d := time.Until(next)
		if d <= 0 {
			return
		}
		if d > 2*time.Millisecond {
			time.Sleep(d - 500*time.Microsecond)
			continue
		}
		// 剩余 <2ms: 自旋补偿
	}
}

func report(name string, n int, elapsed time.Duration, rtt []float64) {
	s := []float64(rtt)
	sort.Float64s(s)
	avg := 0.0
	for _, v := range s {
		avg += v
	}
	if len(s) > 0 {
		avg /= float64(len(s))
	}
	fmt.Printf("[%s] n=%d elapsed=%.1fs rate=%.1f msg/s\n", name, n, elapsed.Seconds(), float64(n)/elapsed.Seconds())
	fmt.Printf("[%s] latency ms: avg=%.3f p50=%.3f p95=%.3f p99=%.3f p99.9=%.3f max=%.3f\n",
		name, avg, pct(s, 0.50), pct(s, 0.95), pct(s, 0.99), pct(s, 0.999), s[len(s)-1])
}

func runNats(p params, mode string) int {
	nc, err := nats.Connect(p.url, nats.MaxReconnects(-1))
	if err != nil {
		fmt.Printf("[nats] connect fail: %v\n", err)
		return 1
	}
	defer nc.Close()

	subj := "mq-bench.echo"
	if mode == "rtt" {
		if _, err := nc.Subscribe(subj, func(m *nats.Msg) { _ = m.Respond([]byte(".")) }); err != nil {
			fmt.Printf("[nats] subscribe fail: %v\n", err)
			return 1
		}
	}

	payload := make([]byte, p.size)
	for i := range payload {
		payload[i] = byte('a' + i%26)
	}
	total := p.rate * p.dur
	rtt := make([]float64, 0, total)
	start := time.Now()
	interval := time.Second / time.Duration(p.rate)
	next := start
	for i := 0; i < total; i++ {
		paceUntil(next)
		next = next.Add(interval)
		t0 := time.Now()
		if mode == "rtt" {
			if _, err := nc.Request(subj, payload, 5*time.Second); err != nil {
				fmt.Printf("[nats] req fail at %d: %v\n", i, err)
				return 1
			}
		} else {
			if err := nc.Publish(subj, payload); err != nil {
				fmt.Printf("[nats] pub fail at %d: %v\n", i, err)
				return 1
			}
		}
		rtt = append(rtt, float64(time.Since(t0).Nanoseconds())/1e6)
		if (i+1)%p.rate == 0 { // 每秒窗口
			fmt.Printf("  [win] t=%.1fs: pace on target\n", float64(i+1)/float64(p.rate))
		}
	}
	elapsed := time.Since(start)
	label := "nats-pubcall"
	if mode == "rtt" {
		label = "nats-rtt"
	}
	report(label, len(rtt), elapsed, rtt)
	return 0
}

func runRabbit(p params) int {
	conn, err := amqp.Dial(p.url)
	if err != nil {
		fmt.Printf("[rabbit] dial fail: %v\n", err)
		return 1
	}
	defer conn.Close()
	// 双 channel: publish 与 consume 分离（同 channel 帧交错触发 unexpected_frame）
	ch, err := conn.Channel()
	if err != nil {
		fmt.Printf("[rabbit] channel fail: %v\n", err)
		return 1
	}
	defer ch.Close()
	consCh, err := conn.Channel()
	if err != nil {
		fmt.Printf("[rabbit] cons channel fail: %v\n", err)
		return 1
	}
	defer consCh.Close()

	const q = "mq-bench-q"
	if _, err := ch.QueueDeclare(q, false, false, false, false, nil); err != nil {
		fmt.Printf("[rabbit] declare fail: %v\n", err)
		return 1
	}
	if err := consCh.Qos(500, 0, false); err != nil {
		fmt.Printf("[rabbit] qos fail: %v\n", err)
		return 1
	}

	events := make(chan time.Duration, p.rate*2)
	consumeErr := make(chan error, 1)
	total := p.rate * p.dur
	var mu sync.Mutex
	var rtt []float64

	// collector: 独立 goroutine 持续 drain events——publish 循环不再阻塞采样，
	// 消费者永不因缓冲满而停摆（停摆曾致队列积压、e2e 分布被排空主导）
	done := make(chan struct{})
	go func() {
		defer close(done)
		for d := range events {
			mu.Lock()
			rtt = append(rtt, float64(d.Nanoseconds())/1e6)
			mu.Unlock()
		}
	}()
	go func() {
		d, err := consCh.Consume(q, "mq-bench-c", false, false, false, false, nil)
		if err != nil {
			consumeErr <- err
			return
		}
		for n := 0; ; n++ {
			e, ok := <-d
			if !ok {
				break
			}
			// 批量 ack: 每 100 条一次（multiple=true 覆盖至当前 delivery）
			if n%100 == 99 {
				_ = e.Ack(true)
			}
			// 零拷贝解析 ts=<nanos> 前缀（避免每条 1KB 的 string 分配）
			b := e.Body
			if len(b) >= 4 && b[0] == 't' && b[1] == 's' && b[2] == '=' {
				sp := 3
				for sp < len(b) && b[sp] != ' ' {
					sp++
				}
				if sp > 3 && sp < len(b) {
					if v, e2 := strconv.ParseInt(string(b[3:sp]), 10, 64); e2 == nil {
						events <- time.Now().Sub(time.Unix(0, v))
					}
				}
			}
		}
		close(events)
	}()

	payload := make([]byte, p.size-8)
	start := time.Now()
	interval := time.Second / time.Duration(p.rate)
	next := start
	for i := 0; i < total; i++ {
		paceUntil(next)
		next = next.Add(interval)
		ts := strconv.FormatInt(time.Now().UnixNano(), 10)
		body := append(append([]byte("ts="+ts), ' '), payload...)
		if err := ch.Publish("", q, false, false, amqp.Publishing{
			ContentType: "text/plain",
			Body:        body,
		}); err != nil {
			fmt.Printf("[rabbit] publish fail at %d: %v\n", i, err)
			return 1
		}
	}
	publishElapsed := time.Since(start)

	// 等消费端收齐（collector 持续 drain，稳态下应紧随 publish 结束）
	deadline := time.After(120 * time.Second)
	for {
		mu.Lock()
		got := len(rtt)
		mu.Unlock()
		if got >= total {
			break
		}
		select {
		case err := <-consumeErr:
			fmt.Printf("[rabbit] consumer fail: %v\n", err)
			return 1
		case <-deadline:
			fmt.Printf("[rabbit] drain timeout, got %d/%d\n", got, total)
			return 1
		case <-time.After(200 * time.Millisecond):
		}
	}
	mu.Lock()
	rtt = rtt[:total]
	mu.Unlock()
	fmt.Printf("[rabbit] publish phase: sent=%d elapsed=%.1fs rate=%.1f msg/s\n",
		total, publishElapsed.Seconds(), float64(total)/publishElapsed.Seconds())
	report("rabbit-e2e", len(rtt), publishElapsed, rtt)
	return 0
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("usage: mq-bench nats|rabbit [flags]")
		os.Exit(2)
	}
	f := flag.NewFlagSet(os.Args[1], flag.ExitOnError)
	p := params{}
	mode := "rtt"
	f.StringVar(&p.url, "url", "", "")
	f.StringVar(&mode, "mode", "rtt", "nats: rtt|pub")
	f.IntVar(&p.rate, "rate", 10000, "target msg/s")
	f.IntVar(&p.dur, "dur", 60, "duration seconds")
	f.IntVar(&p.size, "size", 1024, "payload bytes")
	f.Parse(os.Args[2:])
	switch os.Args[1] {
	case "nats":
		if p.url == "" {
			p.url = "nats://localhost:4222"
		}
		os.Exit(runNats(p, mode))
	case "rabbit":
		if p.url == "" {
			p.url = "amqp://guest:guest@localhost:5672"
		}
		os.Exit(runRabbit(p))
	default:
		fmt.Println("unknown mode", os.Args[1])
		os.Exit(2)
	}
}
