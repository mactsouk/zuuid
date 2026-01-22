const std = @import("std");

/// A Universally Unique Identifier (UUID).
/// Compliant with RFC 4122.
pub const Uuid = struct {
    bytes: [16]u8,

    pub fn v4() Uuid {
        var bytes: [16]u8 = undefined;
        std.crypto.random.bytes(&bytes);

        // Version 4 (0100)
        bytes[6] = (bytes[6] & 0x0f) | 0x40;
        // Variant 1 (10xx)
        bytes[8] = (bytes[8] & 0x3f) | 0x80;

        return Uuid{ .bytes = bytes };
    }

    // Fixed format function
    pub fn format(self: Uuid, writer: anytype) !void {
        var buf: [36]u8 = undefined;
        
        const hex = "{x:0>2}";
        const pattern = hex ++ hex ++ hex ++ hex ++ "-" ++
                        hex ++ hex ++ "-" ++
                        hex ++ hex ++ "-" ++
                        hex ++ hex ++ "-" ++
                        hex ++ hex ++ hex ++ hex ++ hex ++ hex;

        // THE FIX: We add 'catch unreachable'.
        // We know [36]u8 is exactly enough for a UUID, so 'NoSpaceLeft' is impossible.
        // This strips the incompatible error from the return type.
        const slice = std.fmt.bufPrint(&buf, pattern, .{
            self.bytes[0],  self.bytes[1],  self.bytes[2],  self.bytes[3],
            self.bytes[4],  self.bytes[5],
            self.bytes[6],  self.bytes[7],
            self.bytes[8],  self.bytes[9],
            self.bytes[10], self.bytes[11],
            self.bytes[12], self.bytes[13], self.bytes[14], self.bytes[15],
        }) catch unreachable;

        // Now we only return write errors, which std.debug.print accepts.
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

