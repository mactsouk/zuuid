const std = @import("std");
const zuuid = @import("root.zig");

pub fn main(init: std.process.Init) !void {
    var count: usize = 1;
    var use_uppercase: bool = false;

    var iter = init.minimal.args.iterate();
    defer iter.deinit();
    _ = iter.next(); // skip program name
    while (iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "-u")) {
            use_uppercase = true;
        } else if (std.mem.eql(u8, arg, "-n")) {
            if (iter.next()) |num_str| {
                count = try std.fmt.parseInt(usize, num_str, 10);
            }
        }
    }

    var buf: [37]u8 = undefined; // 36 for UUID + 1 for \n
    var i: usize = 0;
    while (i < count) : (i += 1) {
        const id = zuuid.Uuid.v4(init.io);
        const s = if (use_uppercase)
            std.fmt.bufPrint(&buf, "{f}\n", .{id.fmtUpper()}) catch unreachable
        else
            std.fmt.bufPrint(&buf, "{f}\n", .{id}) catch unreachable;
        try std.Io.File.stdout().writeStreamingAll(init.io, s);
    }
}

