SPSC_Queue :: struct (type: Type, capacity: u32) {
    buffer: [capacity] type;
    write_pos: u32 = 0; // atomic
    read_pos: u32 = 0;  // not atomic?

    #run {
        Basic.assert(capacity && (capacity & (capacity - 1)) == 0,
                     "Capacity must be a power of 2!");
    }
}

clear_queue :: (using queue: *SPSC_Queue) {
    read_pos = 0;
    Atomic.atomic_write(*write_pos, 0);
}

queue_empty :: (using queue: *SPSC_Queue) -> bool {
    return read_pos == Atomic.atomic_read(*write_pos);
}

queue_size :: (using queue: *SPSC_Queue) -> u32 {
    return mask(queue, Atomic.atomic_read(*write_pos) - read_pos);
}

// Push an item into the buffer. Will clobber anything unread if it's full.
push_queue :: (using queue: *SPSC_Queue, unit: queue.type) {
    pos := Atomic.atomic_read(*write_pos);
    buffer[pos] = unit;
    Atomic.atomic_write(*write_pos, mask(queue, pos + 1));
}

// Pop an item from the buffer, returns false if no items are available
pop_queue :: (using queue: *SPSC_Queue) -> queue.type, bool {
    item: queue.type = ---;
    if (read_pos != Atomic.atomic_read(*write_pos))
    {
        item = buffer[read_pos];
        read_pos = mask(queue, read_pos + 1);
        return item, true;
    }
    return item, false;
}

#scope_module

mask :: inline (using queue: *SPSC_Queue, val: u32) -> u32 {
    return val & (queue.capacity - 1);
}

Atomic :: #import "Atomics";
Basic :: #import "Basic";

// Implementation is loosely based on:
// https://github.com/surge-synthesizer/sst-cpputils/blob/main/include/sst/cpputils/ring_buffer.h
// (MIT License)
