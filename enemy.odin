package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math"

enemy_range :: 38
enemy_damage :: 25
enemy_attack_cooldown_time :: 0.2

Enemy :: struct {
    using entity: Entity,
    cooldown: f32,
}

new_enemy :: proc(
    x: f32 = 0, y: f32 = 0,
    w: f32 = 8, h: f32 = 8,
    hp: int = entity_default_health) -> Enemy {
    return {
        entity = new_entity(x, y, w, h, hp),
        cooldown = 0,
    }
}

update_enemy :: proc(e: ^Enemy, player: ^Player, tiles: [dynamic]Tile, dt: f32) {
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

    if (e.cooldown > 0) {
        e.cooldown -= dt
    }

    // on player collision
    if (e.cooldown <= 0 && rl.CheckCollisionRecs(e, player)) {
        e.cooldown = enemy_attack_cooldown_time
        entity_damage(player, enemy_damage)
        fmt.println("Player hurt, health = ", player.health)
        // TODO: it should also push player away
    }
}

draw_enemy :: proc(e: Enemy) {
    rl.DrawRectangleRec(e.rec, rl.BLACK)
}
