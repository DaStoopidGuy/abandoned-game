package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math/linalg"
import "core:math"
import "core:mem"

Window :: struct {
    width:  i32,
    height: i32,
    title: cstring,
}

PixelWindowHeight :: 152
win := Window {
    width = 800,
    height = 600,
    title = "Abandoned Game",
}

main :: proc() {
    // tracking memory allocator setup
    // use `-debug` flag 
    when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        context.allocator = mem.tracking_allocator(&track)

        defer {
            if len(track.allocation_map) > 0 {
                fmt.eprintln("==== ", len(track.allocation_map), " allocations not freed: ====")
                for _, entry in track.allocation_map {
                    fmt.eprintln("- ", entry.size, " bytes @ ", entry.location)
                }
            }
            if len(track.bad_free_array) > 0 {
                fmt.eprintln("==== ", len(track.bad_free_array), " incorrect frees: ====")
                for entry in track.bad_free_array {
                    fmt.eprintln("- ", entry.memory, " @ ", entry.location)
                }
            }
            mem.tracking_allocator_destroy(&track)
        }
    }

    fmt.println("Predetermined to be an abandoned project")

    game_init()
    defer game_deinit()
    game_update_and_draw()
}
