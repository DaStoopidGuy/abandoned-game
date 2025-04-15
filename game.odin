package main
import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

Game :: struct {
    camera: rl.Camera2D,
    player: Player,
    enemy: Enemy, // dynamic array of enemies later
    tiles: [dynamic]Tile,
    paused: bool,
}

game := Game {}

game_init :: proc() {
    rl.InitWindow(win.width, win.height, win.title)
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(420)

    load_resources()

    game_set_defaults()
}

game_deinit :: proc() {
    delete(game.tiles)
    unload_resources()
    rl.CloseWindow()
}

game_set_defaults :: proc() {
    using game
    paused = false

    camera = rl.Camera2D{
        offset = rl.Vector2{
            f32(win.width/2), f32(win.height/2)
        },
        target = rl.Vector2(0),
        zoom = f32(win.height)/PixelWindowHeight,
        rotation = 0,
    }

    player = new_player()
    enemy  = new_enemy(x=24)

    levelWidth :: 80
    levelHeight :: 64

    // add grass tiles at bottom of level
    for i := 0; i < levelWidth; i += int(ground_tex.width) {
        tile := Tile{
            rec = {
                width = f32(ground_tex.width),
                height = f32(ground_tex.height),
                x = f32(i),
                y = f32(levelHeight-ground_tex.height),
            },
            texture = ground_tex
        }
        append(&tiles, tile)
    }
}

game_reset :: proc() {
    using game
    // remove previous tiles
    clear(&tiles)
    game_set_defaults()
}

game_loop :: proc() {
    for !rl.WindowShouldClose() {
        dt := rl.GetFrameTime()

        // Input
        get_input()

        if inputs.pause {
            game.paused = !game.paused
        }

        // Update
        if !game.paused do game_update(dt)

        // Draw
        game_draw()
    }
}

game_update :: proc(dt: f32) {
    using game
    // ------------
    // Update

    if inputs.player_teleport_zero {
        player.x = 0
        player.y = 0
        player.vel = 0
        player.on_ground = false
        camera.target = entity_pos(player)
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
    update_enemy(&enemy, &player, tiles, dt)

    pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
    // add tiles on left click
    if (rl.IsMouseButtonDown(.LEFT)) {
        found, _ := get_tile_index(pos, tiles)
        if !found {
            newTile := Tile {
                texture = ground_tex,
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
        posDelta: f32 = rl.Vector2Distance(entity_pos(player), camera.target)
        camera.target = linalg.lerp(camera.target, entity_pos(player), posDelta * 1/1000)
    }
}

game_draw :: proc() {
    using game
    // ------------
    // Draw
    rl.BeginDrawing()
    rl.ClearBackground(rl.BEIGE)

    rl.BeginMode2D(camera)
    for tile in tiles {
        draw_tile(tile)
    }

    draw_player(player)
    draw_enemy(enemy)
    rl.EndMode2D()
    when ODIN_DEBUG {
        rl.DrawFPS(20, 20)
        {
            text := rl.TextFormat("Tiles: %d", len(tiles))
            rl.DrawText(text, win.width - rl.MeasureText(text, 24) - 5, 5, 24, rl.DARKGREEN)
        }
    }
    rl.EndDrawing()
}
