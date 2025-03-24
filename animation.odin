package main

import rl "vendor:raylib"

Animation :: struct {
    texture: rl.Texture2D,
    num_frames: int, // total frames in animation
    frame_length: f32, // duration of one frame (in seconds)
    frame_timer: f32,
    current_frame: int,
}

update_anim :: proc(anim: ^Animation) {
    using anim

    frame_timer += rl.GetFrameTime()

    for frame_timer >= frame_length {
        current_frame += 1
        frame_timer -= frame_length

        if current_frame >= num_frames {
            current_frame = 0
        }
    }
}

draw_anim :: proc(anim: ^Animation, pos: rl.Vector2, flip: bool) {
    using anim

    frame_width := int(texture.width) / num_frames
    frame_height := texture.height

    source := rl.Rectangle {
        x = f32(frame_width * current_frame),
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

    rl.DrawTexturePro(texture, source, dest, 0, 0, rl.WHITE)
}
