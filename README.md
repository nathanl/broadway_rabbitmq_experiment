# Foo

**Note: this repo highlights an issue with producer concurrency > 1 which has been solved in GenStage v1.1.2 and Broadway 1.0.1**.

Demo of confusing behaviors when processing messages using `BroadwayRabbitMQ`.

This simulates a workflow where:

- Each processor should only process 1 message at a time
- Processing a message takes a while and is IO-bound
- We want to maximize concurrency

## Instructions

1. Set environment variables for connecting to an instance of RabbitMQ - see `config/runtime.exs`
2. Run `mix setup_rabbitmq` to create the exchange and queue for this demo
3. `iex -S mix`
4. `Foo.send_messages(100)` to put 100 messages in the queue, to be processed by the Broadway pipeline
5. (Optionally) `Foo.purge()` to purge all messages from the queue

## Good Behavior

Given:

- producer `concurrency: 1`
- 10 processors, each with a `max_demand: 1`
- Each processor sleeping 1 second on getting a message
- 20 messages (`Foo.send_messages(20)`)

We get the behavior we want:

- All messages are delivered concurrently, 1 to each processor
- No processor has messages waiting in their mailbox (which might otherwise be given to an idle processor)
- All processors "work" (sleep) concurrently
- After about 2 seconds, all messages have been processed

## Suboptimal Behavior

If the RabbitMQ `prefetch_count` is less than the processor `concurrency`, we can't keep the processors busy. Eg, if it's `1`, only one message is processed at a time and the other processors are idle. Apparent Lesson: **prefetch count should always be at least as large as processor concurrency**.

## Bad Behavior

Increasing producer `concurrency` has pathological effects.
Eg, with producer `concurrency: 10`, if we `Foo.send_messages(20)`, all 20 messages will be sent to 2 of the 10 processors; each will have a backlog in its mailbox, and the processing will proceed 2 messages at a time as those processors are able.
Meanwhile, all other processors will be idle.

The reason seems to be that each of the producers is sent, and attempts to fill, the demand of each of the processors.
So if 20 messages are in the queue, each of the 10 producers fetches one and hands it to the first processor, then fetches another and hands it to the second processor.
Having no more messages to pull from RabbitMQ, they have nothing to send to the other processors.
**So even though the processors have a `max_demand: 1`, the first two receive 10 messages each, while the others receive none**.

Apparent Lesson: **in cases where the producer does nothing but pull from a queue, having more than one producer will only hurt performance.**

In general, it seems that **any time a processor has messages in its mailbox which it is not currently processing, that's a waste**; those messages could be sitting in the queue or in the producer instead, so that they can be given to the first processor to be or become idle.
