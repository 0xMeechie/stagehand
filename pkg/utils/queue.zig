const std = @import("std");
const mem = std.mem;
const msg = @import("message");

const QueueError = error{
    EmptyQueue,
};

pub const Queue = struct {
    items: std.ArrayList(msg.inbox.Message),
    allocator: mem.Allocator,

    pub fn init(comptime T: type, allocator: mem.Allocator) !Queue {
        return Queue{ .items = std.ArrayList(T).init(allocator), .allocator = allocator };
    }
    pub fn enqueue(self: *Queue, item: msg.inbox.Message) !void {
        try self.items.append(item);
    }
    pub fn dequeue(self: *Queue) error{EmptyQueue}!msg.inbox.Message {
        if (!self.isEmpty()) {
            return self.items.orderedRemove(0);
        }

        return QueueError.EmptyQueue;
    }
    pub fn peek(self: *Queue) void {
        if (!self.isEmpty()) {
            return self.items[0];
        }
    }
    pub fn count(self: *Queue) usize {
        return self.items.items.len;
    }
    pub fn isEmpty(self: *Queue) bool {
        if (self.items.items.len == 0) {
            return true;
        }

        return false;
    }

    pub fn deinit(self: *Queue) void {
        self.items.deinit();
    }
};
