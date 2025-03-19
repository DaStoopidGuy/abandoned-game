package main

import "core:fmt"
import rl "vendor:raylib"

Player :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    tex: rl.Texture2D,
    onGround: bool,
}

update_player :: proc(player: ^Player, tiles: [dynamic]Tile, dt: f32) {
    xMovement := int(rl.IsKeyDown(.RIGHT)) - int(rl.IsKeyDown(.LEFT))
    player.vel.x = f32(xMovement) * 50;

    if rl.IsKeyPressed(.SPACE) && player.onGround {
        player.vel.y = -80
    }

    // gravity
    player.vel.y += 200 * dt

    player.onGround = false

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
                    onGround = true
                }
                else if vel.y < 0 && player_rec.y < tile.rec.y + tile.rec.height {
                    // moving up and collided with bottom side of tile
                    pos.y = tile.rec.y + tile.rec.height
                    vel.y = 0
                }
            }
        }

    }
}

draw_player :: proc(player: Player) {
    rl.DrawTextureV(player.tex, player.pos, rl.WHITE)
}
