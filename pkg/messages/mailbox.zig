const std = @import("std");
const Envelope = @import("envelope.zig").Envelope;

pub const MailBox = struct {
    queue: std.DoublyLinkedList(Envelope),
    lock: std.Thread.Mutex,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) MailBox {
        return .{
            .queue = std.DoublyLinkedList(Envelope){},
            .lock = std.Thread.Mutex{},
            .allocator = allocator,
        };
    }

    pub fn deliver(msg: Envelope) {

    }
};
