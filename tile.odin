package main

import rl "vendor:raylib"

Tile :: struct {
    rec: rl.Rectangle,
    texture: rl.Texture2D,
}

draw_tile :: proc(tile: Tile) {
    rl.DrawTexture(tile.texture, i32(tile.rec.x), i32(tile.rec.y), rl.WHITE)
}
