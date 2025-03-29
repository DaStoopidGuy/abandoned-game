package main

import rl "vendor:raylib"

AnimationPlayer :: struct {
    using anim: Animation,
    cur_frame: int,
    frame_timer: f32,
}

Animation :: struct {
    texture: rl.Texture2D,
    num_frames: int, // total frames in animation
    frame_length: f32, // duration of one frame (in seconds)
}

set_anim :: proc(a: ^AnimationPlayer, anim: Animation) {
    a.anim = anim
}

update_anim :: proc(a: ^AnimationPlayer, dt: f32) {
    a.frame_timer += dt

    for a.frame_timer >= a.frame_length {
        a.cur_frame += 1
        a.frame_timer -= a.frame_length

        if a.cur_frame >= a.num_frames {
            a.cur_frame = 0
        }
    }
}

draw_anim :: proc(a: AnimationPlayer, pos: rl.Vector2, flip: bool) {
    frame_width := int(a.texture.width) / a.num_frames
    frame_height := a.texture.height

    source := rl.Rectangle {
        x = f32(frame_width * a.cur_frame),
        y = 0,
        width = f32(frame_width),
        height = f32(frame_height),
    }
    if flip do source.width *= -1

    dest := rl.Rectangle {
        x = pos.x,
        y = pos.y,
        width = f32(frame_width),
        height = f32(frame_height),
    }

    rl.DrawTexturePro(a.texture, source, dest, 0, 0, rl.WHITE)
}
