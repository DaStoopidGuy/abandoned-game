package main

import "core:fmt"
import rl "vendor:raylib"

Player :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    current_anim: ^Animation,
    on_ground: bool,
}

new_player :: proc() -> Player {
    return {
        current_anim = &player_idle_anim,
        pos = 0,
        vel = 0,
        on_ground = false,
    }
}

update_player :: proc(player: ^Player, tiles: [dynamic]Tile, dt: f32) {
    xMovement := int(rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D)) - int(rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A))
    player.vel.x = f32(xMovement) * 50;

    // jump on space key
    if rl.IsKeyPressed(.SPACE) && player.on_ground {
        player.vel.y = -80
    }

    // gravity
    if (!player.on_ground) do player.vel.y += 200 * dt

    player.on_ground = check_on_ground(player^, tiles)

    { // Collision checking
        using player

        pos.x += vel.x * dt

        for tile in tiles {
            player_rec := rl.Rectangle {
                x = pos.x, y = pos.y,
                width = 8, height = 8
            }
            if rl.CheckCollisionRecs(tile.rec, player_rec) {
                if vel.x > 0 && player_rec.x + player_rec.width > tile.rec.x {
                    // moving right and collided with left side of tile
                    pos.x = tile.rec.x - player_rec.width
                    vel.x = 0
                }
                else if vel.x < 0 && player_rec.x < tile.rec.x + tile.rec.width {
                    // moving left and collided with right side of tile
                    pos.x = tile.rec.x + tile.rec.width
                    vel.x = 0
                }
            }
        }

        pos.y += vel.y * dt

        for tile in tiles {
            player_rec := rl.Rectangle {
                x = pos.x, y = pos.y,
                width = 8, height = 8
            }
            if rl.CheckCollisionRecs(tile.rec, player_rec) {
                if vel.y > 0 && player_rec.y + player_rec.height > tile.rec.y {
                    // moving down and collided with top side of tile
                    pos.y = tile.rec.y - player_rec.height
                    vel.y = 0
                    on_ground = true
                }
                else if vel.y < 0 && player_rec.y < tile.rec.y + tile.rec.height {
                    // moving up and collided with bottom side of tile
                    pos.y = tile.rec.y + tile.rec.height
                    vel.y = 0
                }
            }
        }

    }

    // animation stuff
    // flip sprite based on movement direction
    if xMovement > 0 do player.current_anim.flip = false
    else if xMovement < 0 do player.current_anim.flip = true
    
    if player.vel.x == 0 do player.current_anim = &player_idle_anim
    else do player.current_anim = &player_run_anim

    if !player.on_ground {
        if player.vel.y < 0 do player.current_anim = &player_jump_anim
        else do player.current_anim = &player_fall_anim
    }

    update_anim(player.current_anim)
}

draw_player :: proc(player: Player) {
    draw_anim(player.current_anim, player.pos)
}

@(private="file")
check_on_ground :: proc(player: Player, tiles: [dynamic]Tile) -> bool {
    using player

    for tile in tiles {
        player_foot_collider := rl.Rectangle {
            x = pos.x, y = pos.y + 8,
            width = 8,
            height = 1,
        }

        if rl.CheckCollisionRecs(tile.rec, player_foot_collider) {
            return true
        }
    }
    return false
}
