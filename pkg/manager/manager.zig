const actors = @import("actor");
const envelope = @import("message").envelope;
const std = @import("std");
const utils = @import("utils");
const threads = std.Thread;

const ManagerErrors = error{
    ActorDoesntExist,
};

pub const Engine = struct {
    actors: std.AutoHashMap(u128, actors.actor.ActorStruct),
    messages: utils.queue.Queue,
    allocator: std.mem.Allocator,
    managing: bool,

    pub fn newEngine(allocator: std.mem.Allocator) Engine {
        const queue = try utils.queue.Queue.init(envelope.Envelope, allocator);
        return Engine{
            .allocator = allocator,
            .actors = std.AutoHashMap(u128, actors.actor.ActorStruct).init(allocator),
            .messages = queue,
            .managing = true,
        };
    }

    pub fn manage(self: *Engine) !void {
        while (self.managing) {
            for (0..self.messages.count()) |_| {
                const msg = try self.messages.dequeue();
                try self.route(msg);
            }
            std.debug.print("Hey im running right now", .{});
            std.time.sleep(std.time.us_per_s * 4);
            self.unmanafe();
        }
    }

    pub fn unmanafe(self: *Engine) void {
        self.managing = false;
        std.debug.print("im not going to manage anything right now", .{});
    }

    pub fn route(self: *Engine, msg: envelope.Envelope) !void {
        std.log.info("sending message to {d} from {d} ", .{ msg.recipient.?, msg.sender.? });
        var actorReciever = self.actors.get(msg.recipient.?);

        if (actorReciever == null) {
            return ManagerErrors.ActorDoesntExist;
        }

        try actorReciever.?.addMessage(msg);
    }

    pub fn spawnActor(self: *Engine, behavior: *const fn (msg: envelope.Envelope) void) !void {
        const newActor = actors.actor.ActorStruct.init(self.allocator, "started", behavior);
        try self.actors.put(newActor.id, newActor);
        _ = try threads.spawn(.{}, actors.actor.ActorStruct.run, .{});
    }

    pub fn deinit(self: *Engine) void {
        self.actors.deinit();
        self.messages.deinit();
    }
};
