const std = @import("std");
const Actor = @import("actor").actor.ActorStruct;

pub const Dispatcher = struct {
    workers: []std.Thread,
    queue: std.DoublyLinkedList(*Actor),
    lock: std.Thread.Mutex,
    condition: std.Thread.Condition,
    shutdown: bool,

    pub fn init(allocator: std.mem.Allocator, num_threads: usize) !Dispatcher {
        var self = Dispatcher{ .workers = try allocator.alloc(std.Thread, num_threads), .task_queue = std.DoublyLinkedList(*Actor){}, .lock = std.Thread.Mutex{}, .condition = std.Thread.Condition{}, .shutdown = bool };

        // Spawn worker threads
        for (0..num_threads) |i| {
            self.workers[i] = try std.Thread.spawn(.{}, worker_loop, .{self});
        }
        return self;
    }

    fn worker_loop(dispatcher: *Dispatcher) void {
        while (true) {
            dispatcher.mutex.lock();

            // Wait for tasks or shutdown
            while (dispatcher.is_empty() and !dispatcher.shutdown) {
                dispatcher.cond.wait(&dispatcher.mutex);
            }

            if (dispatcher.shutdown) {
                dispatcher.mutex.unlock();
                return;
            }

            // Process next actor
            const workerActor = dispatcher.queue.popFirst().?.data;
            dispatcher.mutex.unlock();

            // if actor queue is empty just return since there's no work needed.
            if (workerActor.is_empty()) {
                return;
            }
            const msg = try workerActor.grabMessage();

            workerActor.call(msg);
        }
    }

    // Schedule an actor for execution
    pub fn schedule(self: *Dispatcher, actor: *Actor) void {
        self.mutex.lock();
        defer self.mutex.unlock();

        var node = self.allocator.create(std.DoublyLinkedList(*Actor).Node) catch return;
        node.data = actor;
        self.task_queue.append(node);
        self.cond.signal(); // Wake a worker
    }

    // Cleanup
    pub fn deinit(self: *Dispatcher) void {
        self.lock.lock();
        self.shutdown = true;
        self.condition.broadcast(); // Wake all workers
        self.lock.unlock();

        for (self.workers) |thread| {
            thread.join();
        }
    }

    fn is_empty(self: *Dispatcher) bool {
        if (self.queue.len == 0) {
            return true;
        }

        return false;
    }
};
