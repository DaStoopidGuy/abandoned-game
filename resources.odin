package main

import rl "vendor:raylib"

player_run_anim: Animation
player_idle_anim: Animation
player_jump_anim: Animation
player_fall_anim: Animation

ground_tex: rl.Texture2D

load_resources :: proc() {
    player_run_anim = Animation {
        texture = rl.LoadTexture("assets/player_run.png"),
        num_frames = 6,
        frame_length = 0.1,
    }
    player_idle_anim = Animation {
        texture = rl.LoadTexture("assets/player_idle.png"),
        num_frames = 6,
        frame_length = 0.1,
    }
    player_jump_anim = Animation {
        texture = rl.LoadTexture("assets/player_jump.png"),
        num_frames = 3,
        frame_length = 0.1,
    }
    player_fall_anim = Animation {
        texture = rl.LoadTexture("assets/player_fall.png"),
        num_frames = 3,
        frame_length = 0.1,
    }
    ground_tex = rl.LoadTexture("assets/grass-tile.png")
}

unload_resources :: proc() {
    rl.UnloadTexture(player_run_anim.texture)
    rl.UnloadTexture(player_idle_anim.texture)
    rl.UnloadTexture(player_jump_anim.texture)
    rl.UnloadTexture(player_fall_anim.texture)
    rl.UnloadTexture(ground_tex)
}

