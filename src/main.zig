//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const actor = @import("actor").actor;
const std = @import("std");
const msg = @import("message").inbox;
const manager = @import("manager").manager;

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

    try mng.spawnActor(hello);
    while (true) {
        std.debug.print("need to keep this running", .{});
        std.Thread.sleep(std.time.ns_per_s * 2);
    }

    std.debug.print("Did spawn work?", .{});

    var newActor = actor.ActorStruct.init(allcator, "first", hello);
    const secondActor = actor.ActorStruct.init(allcator, "first", hello);

    const newMessage = msg.Message{ .time = 21 + @as(i16, @intCast(12)), .type = msg.MessageType.increase };
    newActor.sendMessage(secondActor.id, newMessage);

    defer newActor.cleanQueue();
}

fn hello(msga: msg.Message) void {
    switch (msga.type) {
        msg.MessageType.increase => {
            std.debug.print("increasing this is the time {d} \n", .{msga.time});
            return;
        },
        msg.MessageType.decrease => {
            std.debug.print("decreasing this is the time {d} \n", .{msga.time});
            return;
        },
    }
    std.debug.print("no matches", .{});
    return;
}
