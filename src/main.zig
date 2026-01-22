const std = @import("std");
const zuuid = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    var count: usize = 1;
    var use_uppercase: bool = false;
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "-u")) {
            use_uppercase = true;
        } else if (std.mem.eql(u8, arg, "-n")) {
            if (args.next()) |num_str| {
                count = try std.fmt.parseInt(usize, num_str, 10);
            }
        }
    }

    var i: usize = 0;
    while (i < count) : (i += 1) {
        const id = zuuid.Uuid.v4();
        if (use_uppercase) {
            std.debug.print("{f}\n", .{id.fmtUpper()});
        } else {
            std.debug.print("{f}\n", .{id});
        }
    }
}

