const std = @import("std");

/// A Universally Unique Identifier (UUID).
/// Compliant with RFC 4122.
pub const Uuid = struct {
    bytes: [16]u8,

    /// Generates a new Version 4 (Random) UUID.
    /// Uses the system's cryptographically secure random number generator.
    pub fn v4() Uuid {
        var bytes: [16]u8 = undefined;
        std.crypto.random.bytes(&bytes);

        // Set Version: 4 (0100)
        bytes[6] = (bytes[6] & 0x0f) | 0x40;

        // Set Variant: RFC 4122 (10xx)
        bytes[8] = (bytes[8] & 0x3f) | 0x80;

        return Uuid{ .bytes = bytes };
    }

    /// Implements custom formatting for the UUID struct.
    /// This allows usage with std.debug.print and std.fmt.allocPrint.
    ///
    /// Supported format specifiers:
    /// - {} or {x}: Standard lowercase hex (e.g., f47ac10b-...)
    /// - {X}: Uppercase hex (e.g., F47AC10B-...)
    pub fn format(
        self: Uuid,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = options;
        
        // Determine case based on format string
        const use_upper = if (fmt.len == 1 and fmt[0] == 'X') true else false;

        // We use a compile-time string to construct the format pattern.
        // This keeps the runtime logic efficient.
        const hex_fmt = if (use_upper) "{X:0>2}" else "{x:0>2}";
        const pattern = hex_fmt ++ hex_fmt ++ hex_fmt ++ hex_fmt ++ "-" ++
                        hex_fmt ++ hex_fmt ++ "-" ++
                        hex_fmt ++ hex_fmt ++ "-" ++
                        hex_fmt ++ hex_fmt ++ "-" ++
                        hex_fmt ++ hex_fmt ++ hex_fmt ++ hex_fmt ++ hex_fmt ++ hex_fmt;

        try std.fmt.format(writer, pattern, .{
            self.bytes[0],  self.bytes[1],  self.bytes[2],  self.bytes[3],
            self.bytes[4],  self.bytes[5],
            self.bytes[6],  self.bytes[7],
            self.bytes[8],  self.bytes[9],
            self.bytes[10], self.bytes[11],
            self.bytes[12], self.bytes[13], self.bytes[14], self.bytes[15],
        });
    }
};

test "basic v4 generation" {
    const uuid = Uuid.v4();
    // Verify version nibble (high nibble of byte 6 should be 4)
    try std.testing.expectEqual(@as(u8, 4), uuid.bytes[6] >> 4);
    // Verify variant nibble (high nibble of byte 8 should be 8, 9, A, or B)
    try std.testing.expectEqual(@as(u8, 2), uuid.bytes[8] >> 6);
}

