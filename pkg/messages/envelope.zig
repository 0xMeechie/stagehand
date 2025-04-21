const Allocator = @import("std").mem.Allocator;

pub const EnvelopeKind = enum { user, system };

pub const Envelope = struct {
    sender: ?u128,
    recipient: ?u128,
    kind: EnvelopeKind,
    msg: *anyopaque,
    deinitFn: ?*const fn (*anyopaque, allocator: *Allocator) void, // optional cleanup

    pub fn newSystemEnvelope(allocator: Allocator, comptime Msg: type, value: *Msg) !Envelope {
        const msg = try allocator.create(Msg);
        msg.* = value.*;
        return Envelope{ .msg = msg, .sender = 12321523432, .recipient = 4324324324234, .deinitFn = null, .kind = .system };
    }

    pub fn newUserEnvelope(allocator: Allocator, comptime Msg: type, value: *Msg) !Envelope {
        const msg = try allocator.create(Msg);
        msg.* = value.*;
        return Envelope{ .msg = msg, .sender = 12321523432, .recipient = 4324324324234, .deinitFn = null, .kind = .user };
    }

    pub fn burnEnvelope(self: Envelope, allocator: Allocator) void {
        const msg_ptr: @TypeOf(self.msg) = @ptrCast(self.msg);
        allocator.destroy(msg_ptr);
    }
};
