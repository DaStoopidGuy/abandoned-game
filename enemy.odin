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

enemy_new :: proc(
    x: f32 = 0, y: f32 = 0,
    w: f32 = 8, h: f32 = 8,
    hp: int = entity_default_health) -> Enemy {
    return {
        entity = entity_new(x, y, w, h, hp),
        anim = { anim = pookie_idle_anim },
        cooldown = 0,
    }
}

enemy_update :: proc(e: ^Enemy, player: ^Player, tiles: [dynamic]Tile, dt: f32) {
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

    entity_update(e, tiles, dt)

    if e.health <= 0 {
        enemy_reset(e)
    }

    if e.cooldown > 0 {
        e.cooldown -= dt
    }

    // on player collision
    if e.cooldown <= 0 && rl.CheckCollisionRecs(e, player) {
        e.cooldown = enemy_attack_cooldown_time
        player_damage(player, enemy_damage)
    }

    // animation stuff
    if e.vel.x != 0 do anim_set(&e.anim, pookie_run_anim)
    else do anim_set(&e.anim, pookie_idle_anim)

    if direction > 0 do e.anim.flip = false
    else if direction < 0 do e.anim.flip = true

    anim_update(&e.anim, dt)
}

enemy_draw :: proc(e: Enemy) {
    anim_draw(e.anim, e.x, e.y)
    entity_draw_health_bar(e)
}

enemy_reset :: proc(e: ^Enemy) {
    e.x, e.y = 0, 0
    e.vel = 0
    e.health = entity_default_health
}
