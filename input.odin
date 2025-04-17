package main

import rl "vendor:raylib"

inputs : struct {
    player_right: bool,
    player_left: bool,
    player_jump: bool,
    player_shoot: bool,
    player_teleport_zero: bool,
    pause: bool,
    game_reset: bool,
}

get_input :: proc() {
    inputs.player_right = rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D)
    inputs.player_left = rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A)
    inputs.player_jump = rl.IsKeyPressed(.UP) || rl.IsKeyPressed(.W)
    inputs.player_shoot = rl.IsKeyPressed(.SPACE)
    inputs.player_teleport_zero = rl.IsKeyPressed(.ZERO)
    inputs.pause = rl.IsKeyPressed(.P)
    inputs.game_reset = rl.IsKeyPressed(.R)
}
