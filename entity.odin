// Entity ---
// - something that can move
// - collides with tiles

package main

import rl "vendor:raylib"

Entity :: struct {
    using rec: rl.Rectangle,
    vel: rl.Vector2,
    on_ground: bool,
}

new_entity :: proc(x: f32 = 0, y: f32 = 0, w: f32 = 8, h: f32 = 8) -> Entity {
    return {
        {
            x = x,
            y = y,
            width = w,
            height = h,
        },
        0,
        false,
    }
}

update_entity :: proc(e: ^Entity, tiles: [dynamic]Tile, dt: f32) {
    e.on_ground = check_on_ground(e^, tiles)

    // horizontal movement + collision
    e.x += e.vel.x * dt

    for tile in tiles {
        if rl.CheckCollisionRecs(e, tile) {
            if e.vel.x > 0 && e.x + e.width > tile.x {
                // Entity moving right and collides with left side of tile
                e.vel.x = 0
                e.x = tile.x - e.width
            }
            else if e.vel.x < 0 && e.x < tile.x + tile.width {
                // Entity moving left and collides with right side of tile
                e.vel.x = 0
                e.x = tile.x + tile.width
            }
        }
    }

    // vertical movement + collision
    e.y += e.vel.y * dt
    
    for tile in tiles {
        if rl.CheckCollisionRecs(e, tile) {
            if e.vel.y > 0 && e.y + e.height > tile.y {
                // Entity moving down and collides with top of tile
                e.vel.y = 0
                e.y = tile.y - e.height
            }
            else if e.vel.y < 0 && e.y < tile.y + tile.height {
                // Entity moving up and collides with bottom of tile
                e.vel.y = 0
                e.y = tile.y + tile.height
            }
        }
    }
}

@(private="file")
check_on_ground :: proc(e: Entity, tiles: [dynamic]Tile) -> bool {
    for tile in tiles {
        entity_foot_collider := rl.Rectangle {
            x = e.x,
            y = e.y + e.height,
            width = e.width,
            height = 1,
        }
        if rl.CheckCollisionRecs(entity_foot_collider, tile) {
            return true
        }
    }
    return false
}

entity_pos :: proc(e: Entity) -> rl.Vector2 {
    return {
        e.x,
        e.y
    }
}
