package main

import "core:fmt"
import rl "vendor:raylib"
import "core:math"

enemy_range :: 38
enemy_damage :: 25
enemy_attack_cooldown_time :: 0.2

Enemy :: struct {
    using entity: Entity,
    anim: AnimationPlayer,
    cooldown: f32,
}

new_enemy :: proc(
    x: f32 = 0, y: f32 = 0,
    w: f32 = 8, h: f32 = 8,
    hp: int = entity_default_health) -> Enemy {
    return {
        entity = new_entity(x, y, w, h, hp),
        anim = { anim = pookie_idle_anim },
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

    direction := math.sign(player.x - e.x)

    if player_in_range && player_in_sight {
        e.vel.x = direction * 30
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
        player_damage(player, enemy_damage)
    }

    // animation stuff
    if e.vel == 0 do set_anim(&e.anim, pookie_idle_anim)
    else do set_anim(&e.anim, pookie_run_anim)

    if direction > 0 do e.anim.flip = false
    else if direction < 0 do e.anim.flip = true

    update_anim(&e.anim, dt)
}

draw_enemy :: proc(e: Enemy) {
    draw_anim(e.anim, e.x, e.y)
}
