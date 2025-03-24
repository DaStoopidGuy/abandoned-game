package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math/linalg"
import "core:math"

Window :: struct {
    width:  i32,
    height: i32,
    title: cstring,
}

main :: proc() {
    PixelWindowHeight :: 152
    win := Window {
        width = 800,
        height = 600,
        title = "Abandoned Game",
    }
    rl.InitWindow(win.width, win.height, win.title)
    defer rl.CloseWindow()

    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(420)

    fmt.println("Predetermined to be an abandoned project")

    levelWidth :: 80
    levelHeight :: 64

    camera := rl.Camera2D{
        offset = rl.Vector2{
            f32(win.width/2), f32(win.height/2)
        },
        target = rl.Vector2(0),
        zoom = f32(win.height)/PixelWindowHeight,
        rotation = 0,
    }

    load_resources()
    defer unload_resources()

    player := new_player()

    groundTexture := rl.LoadTexture("assets/grass-tile.png")
    defer rl.UnloadTexture(groundTexture)

    // all the tiles in the world lol
    tiles: [dynamic]Tile

    // add grass tiles at bottom of level
    for i := 0; i < levelWidth; i += int(groundTexture.width) {
        tile := Tile{
            rec = {
                width = f32(groundTexture.width),
                height = f32(groundTexture.height),
                x = f32(i),
                y = f32(levelHeight-groundTexture.height),
            },
            texture = groundTexture
        }
        append(&tiles, tile)
    }

    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()
        get_input()
        // ------------
        // Update

        if inputs.player_teleport_zero {
            player.pos = 0
            player.vel = 0
            player.on_ground = false
            camera.target = player.pos
        }

        if rl.IsWindowResized() {
            win.width = rl.GetScreenWidth()
            win.height = rl.GetScreenHeight()

            camera.zoom = f32(win.height)/PixelWindowHeight
            camera.offset = {
                f32(win.width)/2,
                f32(win.height)/2
            }
        }

        update_player(&player, tiles, dt)

        pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
        // add tiles on left click
        if (rl.IsMouseButtonDown(.LEFT)) {
            found, _ := get_tile_index(pos, tiles)
            if !found {
                newTile := Tile {
                    texture = groundTexture,
                    rec = {
                        x = math.floor(pos.x/8) * 8,
                        y = math.floor(pos.y/8) * 8,
                        width = 8,
                        height = 8,
                    }
                }
                append(&tiles, newTile)
            }
        }
        
        // remove tiles on right click
        if (rl.IsMouseButtonDown(.RIGHT)) {
            found, index := get_tile_index(pos, tiles)
            if found {
                unordered_remove(&tiles, index)
            }
        }

        { // update camera position
            posDelta: f32 = rl.Vector2Distance(player.pos, camera.target)
            camera.target = linalg.lerp(camera.target, player.pos, posDelta * 1/1000)
        }

        // ------------
        // Draw
        rl.BeginDrawing()
            rl.ClearBackground(rl.BEIGE)

            rl.BeginMode2D(camera)
                for tile in tiles {
                    draw_tile(tile)
                }

                draw_player(player)
            rl.EndMode2D()
            rl.DrawFPS(20, 20)
            {
                text := rl.TextFormat("Tiles: %d", len(tiles))
                rl.DrawText(text, win.width - rl.MeasureText(text, 24) - 5, 5, 24, rl.DARKGREEN)
            }
        rl.EndDrawing()
    }
}
