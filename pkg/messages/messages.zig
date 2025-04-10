pub const MessageType = enum {
    increase,
    decrease,
};

pub const Message = struct {
    type: MessageType,
    time: i16,
    sender: ?u128 = null,
    reciept: ?u128 = null,

    pub fn newMessage(msgType: MessageType, time: i6) void {
        return Message{
            .type = msgType,
            .time = time,
        };
    }

    pub fn startMsg() Message {
        return Message{
            .type = MessageType.decrease,
            .time = 12,
        };
    }
};
