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
    using entity: Entity,
    anim: AnimationPlayer,
    jump_buffer: f32,
    coyote_timer: f32,
}

player_new :: proc() -> Player {
    return {
        entity = entity_new(),
        anim = {anim = player_idle_anim},
    }
}

player_update :: proc(p: ^Player, tiles: [dynamic]Tile, dt: f32) {
    move_speed: f32 = jump_distance / (2 * jump_time_to_peak)

    // check health
    if (p.health <= 0) do game_reset()

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

    // animation stuff
    // flip sprite based on movement direction
    if xMovement > 0 do p.anim.flip = false
    else if xMovement < 0 do p.anim.flip = true
    
    if p.vel.x == 0 do anim_set(&p.anim, player_idle_anim)
    else do anim_set(&p.anim, player_run_anim)

    if !p.on_ground {
        if p.vel.y < 0 do anim_set(&p.anim, player_jump_anim)
        else do anim_set(&p.anim, player_fall_anim)
    }

    entity_update(p, tiles, dt)
    anim_update(&p.anim, dt)
}

player_draw :: proc(player: Player) {
    anim_draw(player.anim, player.x, player.y)
    entity_draw_health_bar(player)
}

player_damage :: proc(player: ^Player, damage: int) {
    entity_damage(player, damage)
    // TODO: it should also push player away
}

@(private="file")
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

@(private="file")
jump :: proc(player: ^Player) {
    jump_velocity: f32 = ((-2.0 * jump_height) / jump_time_to_peak)
    player.vel.y = jump_velocity
    player.jump_buffer = 0
}
