Queue :: #import "spsc-queue";
#import "Basic";

main :: () {
    print("Running SPSC Queue example\n");

    print("Creating a queue...\n");
    queue : Queue.SPSC_Queue(int, 4);
    queue_print(*queue);

    print("Pushing 1 into the queue...\n");
    Queue.push_queue(*queue, 1);
    queue_print(*queue);

    print("Popping 1 from the queue...\n");
    val, success := Queue.pop_queue(*queue);
    assert(success);
    assert(val == 1);
    queue_print(*queue);

    print("Popping null from the queue\n");
    pnull := Queue.pop_queue(*queue);
    val, success = Queue.pop_queue(*queue);
    assert(!success);
    queue_print(*queue);

    print("Clearing the queue\n");
    Queue.clear_queue(*queue);
    queue_print(*queue);

    print("Over-filling the queue\n");
    Queue.push_queue(*queue, 1);
    Queue.push_queue(*queue, 2);
    Queue.push_queue(*queue, 3);
    Queue.push_queue(*queue, 4);
    Queue.push_queue(*queue, 5);
    queue_print(*queue);

    print("Popping from over-filled queue\n");
    val, success = Queue.pop_queue(*queue);
    assert(success);
    assert(val == 5);
    queue_print(*queue);
}

queue_print :: (queue: *Queue.SPSC_Queue) {
    print("Is queue empty: %\n", Queue.queue_empty(queue));
    print("Queue size: %\n\n", Queue.queue_size(queue));
}
