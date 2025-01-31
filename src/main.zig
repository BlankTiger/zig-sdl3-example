const std = @import("std");
const c = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub fn main() !void {
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        return;
    }

    const window = c.SDL_CreateWindow("Window", 400, 600, c.SDL_WINDOW_RESIZABLE) orelse {
        std.debug.print("something went wrong with the window init", .{});
        return;
    };
    const renderer = c.SDL_CreateRenderer(window, undefined) orelse {
        std.debug.print("something went wrong with the renderer init", .{});
        return;
    };

    while (true) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event)) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => {
                    return;
                },
                else => {},
            }
        }

        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderPresent(renderer);
    }
}
