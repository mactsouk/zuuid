const std = @import("std");
const zuuid = @import("root.zig");

pub fn main() !void {
    std.debug.print("--- Testing zuuid Library ---\n", .{});

    var i: usize = 0;
    while (i < 5) : (i += 1) {
        const id = zuuid.Uuid.v4();
        std.debug.print("Generated: {f}\n", .{id});
    }
}
