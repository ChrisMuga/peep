const std = @import("std");
const utils = @import("utils.zig");

test "repeatStr(\"dan\", 3) -> \"dandandan\"" {
    const x = try utils.repeatStr("dan", 3);
    try std.testing.expectEqual(x, "dandandan");
}
