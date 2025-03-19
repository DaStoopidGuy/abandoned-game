package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math/linalg"

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

    playerTexture := rl.LoadTexture("assets/player.png")
    defer rl.UnloadTexture(playerTexture);

    player := Player {
        pos = rl.Vector2(0),
        vel = rl.Vector2(0),
        tex = playerTexture,
        onGround = false,
    }

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
        // ------------
        // Update

        if rl.IsKeyPressed(.ZERO) {
            player.pos = 0
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
        rl.EndDrawing()
    }
}
