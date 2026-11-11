const std = @import("std");
const URL = "http://ipwho.is/";

const Response = struct { success: bool, continent: []const u8, country: []const u8, city: []const u8, capital: []const u8 };

pub fn makeRequest(address: []const u8, allocator: std.mem.Allocator, io: std.Io) !Response {
    var httpClient = std.http.Client{ .allocator = allocator, .io = io };
    var body: std.Io.Writer.Allocating = .init(allocator);

    const full_url = try std.fmt.allocPrint(allocator, "{s}{s}", .{ URL, address });
    defer allocator.free(full_url);

    defer httpClient.deinit();
    defer body.deinit();

    _ = try httpClient.fetch(.{ .location = .{ .url = full_url }, .response_writer = &body.writer });
    return try makeJson(body.written(), allocator);
}

fn makeJson(items: []u8, allocator: std.mem.Allocator) !Response {
    const parsed = try std.json.parseFromSlice(Response, allocator, items, .{ .ignore_unknown_fields = true });
    defer parsed.deinit();

    return parsed.value;
}
