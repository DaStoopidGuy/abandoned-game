package main

import rl "vendor:raylib"
import "core:math"

bullet_damage :: 20
bullet_velocity :: 175
bullet_life_time :: 5 // seconds

Bullet :: struct {
    using rec: rl.Rectangle,
    vel: rl.Vector2,
    alive: bool,
    timer: f32,
}

bullet_new :: proc(x, y: f32, direction: f32) -> Bullet {
    return {
        rec = {
            x, y,
            4, 2,
        },
        vel = {
            bullet_velocity * math.sign(direction),
            0
        },
        alive = true
    }
}

bullet_update :: proc(b: ^Bullet, enemy: ^Enemy, dt: f32) {
    b.x += b.vel.x * dt
    b.y += b.vel.y * dt

    // check collision with enemy
    if (b.alive && rl.CheckCollisionRecs(b, enemy)) {
        entity_damage(enemy, bullet_damage)
        b.alive = false
    }

    // update timer
    b.timer += dt
    if b.timer >= bullet_life_time {
        b.timer = 0
        b.alive = false
    }
}

bullet_draw :: proc(b: Bullet) {
    rl.DrawRectangleRec(b, rl.GOLD)
}
