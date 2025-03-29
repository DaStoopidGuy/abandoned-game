package main

import "core:fmt"
import rl "vendor:raylib"

// jump calculation video:
// - https://youtu.be/IOe1aGY6hXA?si=D_jNq8hGS1tOy1D4
// jump distance calculation:
// - https://www.youtube.com/watch?v=_jdQ_SpBtbM
jump_height :: 16
jump_time_to_peak :: 0.4
jump_time_to_descent :: 0.3
jump_distance :: 40

jump_buffer_time :: 0.1
coyote_time :: 0.1


Player :: struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    anim: AnimationPlayer,
    flip: bool,
    on_ground: bool,
    jump_buffer: f32,
    coyote_timer: f32,
}

new_player :: proc() -> Player {
    return {
        anim = {anim = player_idle_anim},
        pos = 0,
        vel = 0,
        on_ground = false,
    }
}

update_player :: proc(p: ^Player, tiles: [dynamic]Tile, dt: f32) {
    move_speed: f32 = jump_distance / (2 * jump_time_to_peak)

    // horizontal movement
    xMovement := int(inputs.player_right) - int(inputs.player_left)
    p.vel.x = move_speed * f32(xMovement)


    // jump on space key
    if inputs.player_jump {
        p.jump_buffer = jump_buffer_time
    }

    if p.jump_buffer > 0 {
        if p.on_ground || p.coyote_timer > 0 {
            jump(p)
        }
        p.jump_buffer -= dt
    }

    // gravity
    if (!p.on_ground) {
        p.vel.y += get_gravity(p^) * dt
        if (p.coyote_timer > 0) do p.coyote_timer -= dt
    }
    else do p.coyote_timer = coyote_time

    p.on_ground = check_on_ground(p^, tiles)

    { // Collision checking
        p.pos.x += p.vel.x * dt

        for tile in tiles {
            player_rec := rl.Rectangle {
                x = p.pos.x, y = p.pos.y,
                width = 8, height = 8
            }
            if rl.CheckCollisionRecs(tile.rec, player_rec) {
                if p.vel.x > 0 && player_rec.x + player_rec.width > tile.rec.x {
                    // moving right and collided with left side of tile
                    p.pos.x = tile.rec.x - player_rec.width
                    p.vel.x = 0
                }
                else if p.vel.x < 0 && player_rec.x < tile.rec.x + tile.rec.width {
                    // moving left and collided with right side of tile
                    p.pos.x = tile.rec.x + tile.rec.width
                    p.vel.x = 0
                }
            }
        }

        p.pos.y += p.vel.y * dt

        for tile in tiles {
            player_rec := rl.Rectangle {
                x = p.pos.x, y = p.pos.y,
                width = 8, height = 8
            }
            if rl.CheckCollisionRecs(tile.rec, player_rec) {
                if p.vel.y > 0 && player_rec.y + player_rec.height > tile.rec.y {
                    // moving down and collided with top side of tile
                    p.pos.y = tile.rec.y - player_rec.height
                    p.vel.y = 0
                    p.on_ground = true
                }
                else if p.vel.y < 0 && player_rec.y < tile.rec.y + tile.rec.height {
                    // moving up and collided with bottom side of tile
                    p.pos.y = tile.rec.y + tile.rec.height
                    p.vel.y = 0
                }
            }
        }

    }

    // animation stuff
    // flip sprite based on movement direction
    if xMovement > 0 do p.flip = false
    else if xMovement < 0 do p.flip = true
    
    if p.vel.x == 0 do set_anim(&p.anim, player_idle_anim)
    else do set_anim(&p.anim, player_run_anim)

    if !p.on_ground {
        if p.vel.y < 0 do set_anim(&p.anim, player_jump_anim)
        else do set_anim(&p.anim, player_fall_anim)
    }

    update_anim(&p.anim, dt)
}

draw_player :: proc(player: Player) {
    draw_anim(player.anim, player.pos, player.flip)
}

@(private="file")
check_on_ground :: proc(p: Player, tiles: [dynamic]Tile) -> bool {
    for tile in tiles {
        player_foot_collider := rl.Rectangle {
            x = p.pos.x, y = p.pos.y + 8,
            width = 8,
            height = 1,
        }

        if rl.CheckCollisionRecs(tile.rec, player_foot_collider) {
            return true
        }
    }
    return false
}

get_gravity :: proc(player: Player) -> f32 {
    if player.vel.y > 0 {
        fall_gravity: f32 = (2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent) 
        return fall_gravity
    }
    else {
        jump_gravity: f32 = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak) 
        return jump_gravity
    }
}

jump :: proc(player: ^Player) {
    jump_velocity: f32 = ((-2.0 * jump_height) / jump_time_to_peak)
    player.vel.y = jump_velocity
    player.jump_buffer = 0
}
