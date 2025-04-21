//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const actor = @import("actor").actor;
const std = @import("std");
const msg = @import("message").inbox;
const envelope = @import("message").envelope;
const manager = @import("manager").manager;

const Tessss = struct {
    pizza: bool,
};

const Yesss = struct {
    popcorn: bool,
};

const OhYeah = union(enum) { Tessss, Yesss };

fn worke(f: msg.Messagex) void {
    std.debug.print("Does this work {any}", .{f.time});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allcator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) {
            std.debug.print("got yourself a leak", .{});
        }
    }
    var mng = manager.Engine.newEngine(allcator);
    defer mng.deinit();
    try mng.manage();

    var TessMessage = try allcator.create(msg.NewMessage(OhYeah));
    TessMessage = try msg.NewMessage(OhYeah).spawn(allcator);

    const newenv = try envelope.Envelope.newSystemEnvelope(allcator, msg.NewMessage(Tessss), TessMessage);

    var newActor = actor.ActorStruct.init(allcator, "started", TestBehavior);
    newActor.call(newenv);

    std.debug.print("what is this? {any}\n", .{newenv});

    std.debug.print("Did spawn work?", .{});
}

fn TestBehavior(message: envelope.Envelope) void {
    //const msgr = @ptrCast(*msg.NewMessage(Tessss))(message.msg);
    //const msgr: *msg.NewMessage(Tessss) = @ptrCast(*align(@alignOf(msg.NewMessage(Tessss))) &message.msg);
    //const msgr: *msg.NewMessage(Tessss) = @alignCast(@ptrCast(&message.msg));
    const msgr: *msg.NewMessage(OhYeah) = @constCast(@alignCast(@ptrCast(&message.msg)));
    const payload = msgr.*.payload;

    switch (payload) {
        .system => |sys_msg| {
            switch (sys_msg) {
                .healthcheck => {},
                .kill => {},
                .spawn => {},
            }
        },
        .user => |user_msg| {
            switch (user_msg.custom) {
                .Tessss => {},
                .Yesss => {},
            }
        },
    }
}
