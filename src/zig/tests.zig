const std = @import("std");
const utils = @import("utils.zig");

test "repeat(\"dan\", 3) -> \"dandandan\"" {
    const allocator = std.testing.allocator;

    const repeated = try utils.repeat(allocator, "dan", 3);
    defer allocator.free(repeated);

    try std.testing.expectEqualStrings(repeated, "dandandan");
}

test "isFlag(\"--help\") -> true" {
    const res = utils.isFlag("--help");
    try std.testing.expectEqual(res, true);
}

test "isFlag(\"help--\") -> false" {
    const res2 = utils.isFlag("help--");
    try std.testing.expectEqual(res2, false);
}
