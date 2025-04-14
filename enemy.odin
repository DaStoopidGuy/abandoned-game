package main

import rl "vendor:raylib"
import "core:math"

enemy_range :: 38

Enemy :: struct {
    using entity: Entity,
}

new_enemy :: proc() -> Enemy {
    return {
        new_entity(),
    }
}

update_enemy :: proc(e: ^Enemy, player: Player, tiles: [dynamic]Tile, dt: f32) {
    // gravity
    if !e.on_ground {
        e.vel.y += 90 * dt
    }

    // follow player
    player_in_range := rl.Vector2Distance(entity_pos(e), entity_pos(player)) < enemy_range
    player_in_sight := player.y < e.y+e.height && player.y+player.height > e.y

    if player_in_range && player_in_sight {
        e.vel.x = math.sign(player.x - e.x) * 30
    }
    else {
        e.vel.x = 0
    }

    update_entity(e, tiles, dt)
}

draw_enemy :: proc(e: Enemy) {
    rl.DrawRectangleRec(e.rec, rl.BLACK)
}
