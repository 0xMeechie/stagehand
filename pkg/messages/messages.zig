const std = @import("std");
const time = std.time;
const Allocator = std.mem.Allocator;

pub fn UserMsg(comptime customUserMsg: type) type {
    return union(enum) {
        custom: customUserMsg,

        pub fn init(msg: customUserMsg) @This() {
            return .{ .custom = msg };
        }
    };
}

pub fn NewMessage(comptime CustomUserMsg: type) type {
    const UserPayload = UserMsg(CustomUserMsg);

    return struct {
        type: MessageType,
        payload: Payload,
        time: i64,
        sender: ?u128 = null,
        recipient: ?u128 = null,

        pub const MessageType = enum {
            system,
            user,
        };

        pub const SystemMsg = enum {
            spawn,
            healthcheck,
            kill,
        };

        pub const Payload = union(enum) {
            system: SystemMsg,
            user: UserPayload,
        };

        pub fn spawn(allocator: Allocator) !*@This() {
            const msg = try allocator.create(@This());
            msg.* = @This(){
                .type = .system,
                .time = time.timestamp(),
                .sender = null,
                .recipient = null,
                .payload = .{ .system = .spawn },
            };
            return msg;
        }

        pub fn kill(allocator: Allocator) !*@This() {
            const msg = try allocator.create(@This());
            msg.* = @This(){
                .type = .system,
                .time = time.timestamp(),
                .sender = null,
                .recipient = null,
                .payload = .{ .system = .kill },
            };
            return msg;
        }

        pub fn healthcheck(allocator: Allocator) !*@This() {
            const msg = try allocator.create(@This());
            msg.* = @This(){
                .type = .system,
                .time = time.timestamp(),
                .sender = null,
                .recipient = null,
                .payload = .{ .system = .healthcheck },
            };
            return msg;
        }

        pub fn newMessage(allocator: Allocator, userMsg: CustomUserMsg) !*@This() {
            const msg = try allocator.create(@This());
            msg.* = @This(){
                .type = .system,
                .time = time.timestamp(),
                .sender = null,
                .recipient = null,
                .payload = .{ .user = userMsg }, // or use a variable like `spawning`
            };
            return msg;
        }
    };
}
