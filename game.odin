package main
import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"

Game :: struct {
    camera: rl.Camera2D,
    player: Player,
    enemy: Enemy, // dynamic array of enemies later
    tiles: [dynamic]Tile,
    bullets: [dynamic]Bullet,
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
    delete(game.bullets)
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

    player = player_new()
    enemy  = enemy_new(x=24)

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
        if inputs.game_reset do game_reset()

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

    player_update(&player, dt)
    update_bullets(dt)
    enemy_update(&enemy, &player, tiles, dt)

    pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
    // add tiles on left click
    if (rl.IsMouseButtonDown(.LEFT)) {
        found, _ := tile_index_from_pos(pos, tiles)
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
        found, index := tile_index_from_pos(pos, tiles)
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
    // ------------
    // Draw
    rl.BeginDrawing()
    rl.ClearBackground(rl.BEIGE)

    rl.BeginMode2D(game.camera)
    for tile in game.tiles {
        tile_draw(tile)
    }

    player_draw(game.player)
    draw_bullets()
    enemy_draw(game.enemy)
    rl.EndMode2D()
    if game.paused {
        text :: "PAUSED"
        rl.DrawText(text, win.width/2 - rl.MeasureText(text, 20)/2, 10, 20, rl.RED)
    }
    when ODIN_DEBUG {
        rl.DrawFPS(20, 20)
        {
            text := rl.TextFormat("Tiles: %d", len(game.tiles))
            rl.DrawText(text, win.width - rl.MeasureText(text, 24) - 5, 5, 24, rl.DARKGREEN)
        }
    }
    rl.EndDrawing()
}

update_bullets :: proc(dt: f32) {
    for &bullet, idx in game.bullets {
        if !bullet.alive {
            unordered_remove(&game.bullets, idx)
            continue
        }
        bullet_update(&bullet, &game.enemy, dt)
    }
}

draw_bullets :: proc() {
    for bullet in game.bullets {
        bullet_draw(bullet)
    }
}
