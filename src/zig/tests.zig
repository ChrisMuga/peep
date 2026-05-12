const std = @import("std");
const utils = @import("utils.zig");

test "repeatStr(\"dan\", 3) -> \"dandandan\"" {
    const allocator = std.testing.allocator;
    const x = try utils.repeatStr(allocator, "dan", 3);
    defer allocator.free(x);

    try std.testing.expectEqualStrings(x, "dandandan");
}
