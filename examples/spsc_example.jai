queue: Queue.SPSC_Queue(u32, 32);

write_thread: Thread.Thread;
read_thread: Thread.Thread;

N : u32 : 64;

write_thread_proc :: (thread: *Thread.Thread) -> s64 {
    print("Starting writer thread\n");

    count := cast(*u32) thread.data;
    count.* = 0;

    while count.* < N {
        count.* += 1;
        // print("Pushing to queue: %\n", count);
        Queue.push_queue(*queue, count.*);
        sleep_milliseconds(1);
    }

    print("Final write count: %\n", count.*);
    return 0;
}

read_thread_proc :: (thread: * Thread.Thread) -> s64 {
    print("Starting reader thread\n");

    count := cast(*u32) thread.data;
    count.* = 0;

    while count.* < N {
        new_count, success := Queue.pop_queue(*queue);
        if !success {
            // print("Skipping read!\n");
            continue;
        }
        assert(new_count == count.* + 1, tprint("Expected %, received %\n", count.* + 1, new_count));
        count.* = new_count;
        // print("Popped from queue: %\n", count);
    }

    print("Final read count: %\n", count.*);
    return 0;
}

main :: () {
    print("Running SPSC Example!\n");

    write_count: u32;
    write_thread.data = *write_count;
    Thread.thread_init(*write_thread, write_thread_proc);
    defer Thread.thread_deinit(*write_thread);

    read_count: u32;
    read_thread.data = *read_count;
    Thread.thread_init(*read_thread, read_thread_proc);
    defer Thread.thread_deinit(*read_thread);

    Thread.thread_start(*write_thread);
    Thread.thread_start(*read_thread);

    while atomic_read(*read_count) < N {
        sleep_milliseconds(10);
    }
}

#import "Atomics";
#import "Basic";
Queue :: #import "spsc-queue";
Thread :: #import "Thread";
