const std = @import("std");

pub const Uuid = struct {
    bytes: [16]u8,

    pub fn v4() Uuid {
        var bytes: [16]u8 = undefined;
        std.crypto.random.bytes(&bytes);
        bytes[6] = (bytes[6] & 0x0f) | 0x40;
        bytes[8] = (bytes[8] & 0x3f) | 0x80;
        return Uuid{ .bytes = bytes };
    }

    // 1. Default lowercase formatter (matches {f} and {})
    pub fn format(self: Uuid, writer: anytype) !void {
        try formatHex(self, writer, false);
    }

    // 2. Uppercase helper
    // Returns a wrapper struct that has its own format() method.
    pub fn fmtUpper(self: Uuid) FormatterUpper {
        return .{ .uuid = self };
    }

    // The wrapper struct for uppercase printing
    pub const FormatterUpper = struct {
        uuid: Uuid,
        pub fn format(self: FormatterUpper, writer: anytype) !void {
            try formatHex(self.uuid, writer, true);
        }
    };

    // Internal helper to avoid code duplication
    fn formatHex(uuid: Uuid, writer: anytype, comptime upper: bool) !void {
        var buf: [36]u8 = undefined;
        // Select format string at compile time
        const hex = if (upper) "{X:0>2}" else "{x:0>2}";
        const pattern = hex ++ hex ++ hex ++ hex ++ "-" ++
                        hex ++ hex ++ "-" ++
                        hex ++ hex ++ "-" ++
                        hex ++ hex ++ "-" ++
                        hex ++ hex ++ hex ++ hex ++ hex ++ hex;

        const slice = std.fmt.bufPrint(&buf, pattern, .{
            uuid.bytes[0],  uuid.bytes[1],  uuid.bytes[2],  uuid.bytes[3],
            uuid.bytes[4],  uuid.bytes[5],
            uuid.bytes[6],  uuid.bytes[7],
            uuid.bytes[8],  uuid.bytes[9],
            uuid.bytes[10], uuid.bytes[11],
            uuid.bytes[12], uuid.bytes[13], uuid.bytes[14], uuid.bytes[15],
        }) catch unreachable; // Safe because buf is exactly 36 bytes

        _ = try writer.write(slice);
    }
};

test "basic v4 generation" {
    const uuid = Uuid.v4();
    // Verify version nibble (high nibble of byte 6 should be 4)
    try std.testing.expectEqual(@as(u8, 4), uuid.bytes[6] >> 4);
    // Verify variant nibble (high nibble of byte 8 should be 8, 9, A, or B)
    try std.testing.expectEqual(@as(u8, 2), uuid.bytes[8] >> 6);
}

