const std = @import("std");

pub fn main() !void {
    // _ = try streamTwo();
    _ = try streamIn();
    // _ = try readIn();
}

pub fn readIn() !void {
    std.debug.print("starting read...\n", .{});
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());

    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        // std.debug.print("{s}\n", .{line});
        _ = line;
    }
}

pub fn streamIn() !void {
    std.debug.print("starting stream...\n", .{});
    var buf_reader = std.io.bufferedReader(std.io.getStdIn().reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var buf_stream = std.io.fixedBufferStream(&buf);

    var line_count: u32 = 0;
    while (true) {
        defer buf_stream.reset();

        in_stream.streamUntilDelimiter(buf_stream.writer(), '\n', null) catch |err|
            switch (err) {
            error.EndOfStream => {
                break;
            },
            error.StreamTooLong => {
                std.debug.print("{any}", .{err});
                break;
            },
            else => {
                return err;
            },
        };

        line_count = line_count + 1;
        // std.debug.print("{s}\n", .{buf_stream.getWritten()});
    }
    std.debug.print("{d}", .{line_count});
}

fn streamTwo() !void {
    std.debug.print("stream two...\n", .{});
    var gpa_server = std.heap.GeneralPurposeAllocator(.{}){};
    var salloc = gpa_server.allocator();

    var buf = try std.ArrayList(u8).initCapacity(salloc, 32);
    defer buf.deinit();

    const w = buf.writer();
    const r = std.io.getStdIn().reader();
    while (true) {
        defer buf.clearRetainingCapacity(); // since we're reusing the buffer
        r.streamUntilDelimiter(w, '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => |e| return e,
        };
        // const line = std.mem.trimRight(u8, buf.items, "\r\n");
        // std.debug.print("Line '{s}'\n", .{line});
    }

    std.debug.print("END OF STREAM REACHED\n", .{});
}

// pub fn readInStream() !void {
//     const input_string = "some_string_with_delimiter!";
//     var input_fbs = std.io.fixedBufferStream(input_string);
//     const reader = input_fbs.reader();
//
//     var output: [input_string.len]u8 = undefined;
//     var output_fbs = std.io.fixedBufferStream(&output);
//     const writer = output_fbs.writer();
//
//     while (try reader.readUntilDelimiterOrEof(&buf,'\n')) |line| {
//         std.debug.print("{d}", .{line});
//     }
// }

// test "Reader.streamUntilDelimiter writes all bytes without delimiter to the output" {
//     const input_string = "some_string_with_delimiter!";
//     var input_fbs = std.io.fixedBufferStream(input_string);
//     const reader = input_fbs.reader();
//
//     var output: [input_string.len]u8 = undefined;
//     var output_fbs = std.io.fixedBufferStream(&output);
//     const writer = output_fbs.writer();
//
//     try reader.streamUntilDelimiter(writer, '!', op);
//     try std.testing.expectEqualStrings("some_string_with_delimiter", output_fbs.getWritten());
//     try std.testing.expectError(error.EndOfStream, reader.streamUntilDelimiter(writer, '!', input_fbs.buffer.len));
//
//     input_fbs.reset();
//     output_fbs.reset();
//
//     try std.testing.expectError(error.StreamTooLong, reader.streamUntilDelimiter(writer, '!', 5));
// }

// test "stremer" {
//     _ = try readInStream();
// }
