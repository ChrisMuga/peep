const std = @import("std");
const utils = @import("utils.zig");

const print = std.debug.print;
const fs = std.fs;

/// # Task:
///      - Take a file as command line input and print its output/contents
///      - Input must be a file and not, say, a directory
///      - Show line numbers
///      - Print specific line numbers if specified e.g peep test.txt 40 - prints L40 only
///      - Print specific range of line numbers if specified e.g peep test.txt 40-50 - prints L40-L50
/// ## Implementation:
///     - Use an arena allocator to create a buffer.
///     - Use that buffer to read the file specified.
///     - Obtain the file size in order to know how much buffer memory we need to read the whole file
///     - Parse the file while streaming, if we run into a '\n' character; we use that to denote line numbers
///     - Prepend line number at the beginning of every line, which means we initialize our line numbers at 1.
///     - Deintialize the arena on function close
///     - Free the buffer memory on function close
/// ### Examples:
///     - ./zig-out/bin/peep example.txt // To print the whole file
///     - ./zig-out/bin/peep example.txt 14 // To print line 14 only
///     - ./zig-out/bin/peep example.txt 14:20 // To print lines 14 to 20

// TODO: Get started with tests
// TODO: Implement man page for peep
// TODO: Implement piping e.g. `git log | peep`
// TODO: Look into semver - semantic versioning
// TODO: use @cImport to run C code in zig
// TODO: peep test.txt:10
// TODO: peep test.txt:10:20
// TODO: Error handling in case:
//  - peep test.txt e (if line specifier A is invalid)
//  - peep test.txt 50:e (if line specifier B is invalid)
//  - peep test.txt 50-60 ("-" is an invalid delimiter)
//  - peep test.txt 50kk-60sk (either of the specifiers are not non-zero numbers)
pub fn main(init: std.process.Init) !void {
    // var args = std.process.args(); // Works on POSIX only, not windows
    //  - the implementation below should work for both.
    //  - TODO: Confirm
    // const global_allocator = std.heap.page_allocator;
    const args = try init.minimal.args.toSlice(init.arena.allocator());

    var args_buffer: [10][]const u8 = undefined;

    var j: u8 = 0;

    // We only need args[1-2] here so we'll exit the loop early.
    for (args, 0..) |x, idx| {
        _ = idx;

        args_buffer[j] = x;
        j += 1;

        if (j == 3) {
            break;
        }
    }

    // Specified line number(s) - sln
    var sln_a: ?u64 = null;
    var sln_b: ?u64 = null;

    if (j <= 1) {
        utils.handleFlagVersion();
        utils.handleFlagHelp();
        return;
    } else if (j == 2) {
        // Check and handle early if we run into a flag
        const flag: []const u8 = args_buffer[1];

        if (utils.isFlag(flag)) {
            utils.handleFlag(flag);
            return;
        }
    } else if (j == 3) {
        utils.cls();
        var range_split = std.mem.splitSequence(u8, args_buffer[2], ":");
        var i: u8 = 0;
        while (range_split.next()) |x| {
            switch (i) {
                0 => {
                    sln_a = try std.fmt.parseInt(u64, x, 10);
                },
                1 => {
                    if (x.len > 0) {
                        sln_b = try std.fmt.parseInt(u64, x, 10);
                    }
                },
                else => {},
            }
            i += 1;
        }
    }

    const file_name = args_buffer[1];

    if (sln_a != null and sln_b != null) {
        utils.echo("-------");
        print("Showing L{d}-L{d} of {s}\n", .{ sln_a.?, sln_b.?, file_name });
    } else if (sln_a != null and sln_b == null) {
        utils.echo("-------");
        print("Showing {s}:{d}\n", .{ file_name, sln_a.? });
    }

    var threaded: std.Io.Threaded = .init_single_threaded;
    const io = threaded.io();
    const cwd = std.Io.Dir.cwd();
    if (cwd.openFile(io, file_name, .{})) |file| {
        const stat = try file.stat(io);
        if (stat.kind != std.Io.File.Kind.file) {
            if (stat.kind == std.Io.File.Kind.directory) {
                // TODO: List root directory entries
                print("{s} is a directory\n", .{file_name});
                const dir = try std.Io.Dir.openDir(cwd, io, file_name, .{ .iterate = true });
                defer dir.close(io);
                var dirIterator = std.Io.Dir.iterate(dir);

                while (try dirIterator.next(io)) |v| {
                    // TODO: Some sort of formatting, and spacing here when listing a dir.
                    // TODO: On surface level, if entry is dir, flag it, if it is a file, flag it as well.
                    print("\t-> {s}\n", .{v.name});
                }

                return;
            }

            print("Error: {s} is not a file\n", .{file_name});
            return;
        }

        const file_size = stat.size;

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        const buffer = try allocator.alloc(u8, file_size);
        defer allocator.free(buffer);

        // TODO: I don't understand what's going on here, we should investigate.
        //      - See: https://github.com/ziglang/zig/pull/25592
        //      - See: https://www.reddit.com/r/Zig/comments/1oo8u5z/can_someone_explain_to_me_the_new_stdio_interface/
        //      - I don't understand why we had to add the io
        var reader = file.reader(io, buffer);

        // TODO: There may be a better implementation here...
        if (reader.interface.readSliceAll(buffer)) |_| {} else |err| {
            print("{any}", .{err});
        }

        var y: usize = 0;
        var line_no: u64 = 0;

        for (buffer) |c| {
            if ((y == 0) or (buffer[y - 1] == '\n')) {
                line_no += 1;
                if (sln_a == null or sln_a == line_no) {
                    if (sln_a == line_no) {
                        utils.echo("-------");
                    }
                    print("{d} \t", .{line_no});
                }

                if (sln_b != null and sln_b.? >= line_no and line_no > sln_a.?) {
                    print("{d} \t", .{line_no});
                }
            }

            if (sln_a == null or sln_a == line_no) {
                print("{c}", .{c});
            }

            if (sln_b != null and (sln_b.? >= line_no and line_no > sln_a.?)) {
                print("{c}", .{c});
            }

            y += 1;
        }

        if (sln_a == null) {
            utils.echo("\n-------");
            print("Size: {d} bytes\n", .{file_size});
            utils.echo("-------");
        } else {
            if (sln_a.? <= line_no) {
                utils.echo("-------");
            } else {
                print("Cannot find line({d}). Max line number is {d}\n", .{ sln_a.?, line_no });
            }
        }
    } else |_| {
        print("Error: Cannot locate/open file ({s})\n", .{file_name});
    }
}
