const std = @import("std");

/// # Implementation
/// - mimics `print("Hello World")` in Python3
/// ## Example usage:
/// - echo("Hello World");
pub fn echo(val: []const u8) void {
    std.debug.print("{s}\n", .{val});
}

pub fn cls() void {
    std.debug.print("\x1B[2J\x1B[H", .{});
}

pub const FLAG_HELP = "--help";
pub const FLAG_ZEN = "--zen";
pub const FLAG_VERSION = "--version";

/// isFlag checks the 1st command line args to see if it is prepended by "--"
pub fn isFlag(val: []const u8) bool {
    return std.mem.eql(u8, "--", val[0..2]);
}

pub fn handleFlag(flag: []const u8) void {
    if (std.mem.eql(u8, flag, FLAG_HELP)) {
        handleFlagHelp();
    } else if (std.mem.eql(u8, flag, FLAG_ZEN)) {
        handleFlagZen();
    } else if (std.mem.eql(u8, flag, FLAG_VERSION)) {
        handleFlagVersion();
    } else {
        std.debug.print("Error: {s} is not a valid argument\n", .{flag});
    }
}

pub fn handleFlagHelp() void {
    std.debug.print(
        \\Usage: peep [file | args]
        \\-----
        \\peep file.txt
        \\peep file.txt 40 (prints L40 only)
        \\peep file.txt 40:50 (prints L40-L50)
        \\-----
        \\ - Take a file as command line input and print its output/contents
        \\ - Input must be a file and not, say, a directory
        \\ - Show line numbers
        \\ - Print specific line numbers if specified e.g peep test.txt 40 - prints L40 only
        \\ - Print specific range of line numbers if specified e.g peep test.txt 40-50 - prints L40-L50
        \\-----
        \\args:
        \\  --help                 shows help manual/documentation
        \\  --zen                  shows zen
        \\  --version              shows version
        \\
    , .{});
}

pub fn handleFlagZen() void {
    echo("\"Dust thou art - to dust returnest; was not spoken of the soul\" ;)");
}

pub fn handleFlagVersion() void {
    echo("v0.0.1");
}

// TODO: repeatStr is not working, fix.
pub fn repeatStr(elem: []const u8, times: usize) ![] u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const res = try allocator.alloc(u8, times * elem.len);

    var count: i8 = 0;

    while (count < times) {
        const x = try std.mem.concat(allocator, u8, &.{res, elem});
        @memcpy(res, x);
        count += 1;
    }

    std.debug.print("{s}\n", .{elem});
    std.debug.print("~~~~>{s}|\n", .{res});
    return res;
}

pub fn listDir(dir: std.Io.Dir, file_name: []const u8) !void {
    var level: usize = 0;
    // std.debug.print("{s}/\n", .{file_name});

    var threaded: std.Io.Threaded = .init_single_threaded;
    const io = threaded.io();
    const currDir = try std.Io.Dir.openDir(dir, io, file_name, .{ .iterate = true });

    defer currDir.close(io);
    var dirIterator = std.Io.Dir.iterate(currDir);

    _ = try repeatStr("dan", level);
    const sep = "";

    while (try dirIterator.next(io)) |v| {
        if (v.kind == std.Io.File.Kind.directory) {
            level += 1;

            std.debug.print("{s} {s}/*\n", .{ v.name, sep });
            try listDir(currDir, v.name);
        } else {
            std.debug.print("{s} {s}\n", .{ v.name, sep });
        }
    }
}
