const std = @import("std");
const Io = std.Io;

const ZigRequest = @import("ZigRequest");
const http_request = @import("request/http_request.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const args = try init.minimal.args.toSlice(allocator);

    if (args.len <= 1) {
        std.log.debug("Insufficent arguments", .{});
        return;
    }

    for (args[1..]) |argument| {
        if (args.len < 2) {
            std.log.err("Put the ip address", .{});
            break;
        }

        const response = try http_request.makeRequest(argument, allocator, init.io);

        if (!response.success) {
            std.log.err("Can't process this address", .{});
            break;
        }

        std.log.debug("Success: {}", .{response.success});
        std.log.debug("Continent: {s}", .{response.continent});
        std.log.debug("Country: {s}", .{response.country});
        std.log.debug("City: {s}", .{response.city});
        std.log.debug("Capital: {s}", .{response.capital});
    }
}
