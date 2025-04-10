const std = @import("std");
const uuid = @import("uuid");
const utils = @import("utils");
const msg = @import("message");

pub const ActorStruct = struct {
    id: u128,
    queue: utils.queue.Queue,
    status: []const u8,
    behavior: *const fn (message: msg.inbox.Message) void,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, status: []const u8, behavior: *const fn (message: msg.inbox.Message) void) ActorStruct {
        const queue = try utils.queue.Queue.init(msg.inbox.Message, allocator);
        return ActorStruct{
            .id = uuid.v7.new(),
            .queue = queue,
            .status = status,
            .behavior = behavior,
            .allocator = allocator,
        };
    }

    pub fn addMessage(self: *ActorStruct, message: msg.inbox.Message) !void {
        try self.queue.enqueue(message);
    }

    pub fn grabMessage(self: *ActorStruct) !msg.inbox.Message {
        return self.queue.dequeue();
    }

    pub fn grabQueueCount(self: *ActorStruct) usize {
        return self.queue.count();
    }

    pub fn call(self: *ActorStruct) void {
        self.behavior(self.message);
    }

    pub fn cleanQueue(self: *ActorStruct) void {
        self.queue.deinit();
    }

    pub fn run() void {
        while (true) {
            std.debug.print("My ID is .{d}\n", .{94239748973298});
            std.debug.print("going to take a nap\n", .{});
            std.Thread.sleep(std.time.ns_per_s * 5);
            std.debug.print("That was a good nap.Time to get to work\n", .{});
        }
    }

    pub fn sendMessage(self: *ActorStruct, target_actor: u128, message: msg.inbox.Message) void {
        //put message in inbox of other Actor
        //We want to send this to the manager and let the manager send it to the direct actor
        std.debug.print("myIDis {d}\n", .{self.id});
        std.debug.print("Actor ID is {d}\n", .{target_actor});
        std.debug.print("Message is {d}\n", .{message.time});
    }
};
