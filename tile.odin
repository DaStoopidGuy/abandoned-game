package main

import rl "vendor:raylib"

Tile :: struct {
    using rec: rl.Rectangle,
    texture: rl.Texture2D,
}

tile_draw :: proc(tile: Tile) {
    rl.DrawTexture(tile.texture, i32(tile.rec.x), i32(tile.rec.y), rl.WHITE)
}

tile_index_from_pos :: proc(pos: rl.Vector2, tiles: [dynamic]Tile) -> (bool, int) {
    for tile, index in tiles {
        if rl.CheckCollisionPointRec(pos, tile.rec) {
            return true, index
        }
    }
    return false, len(tiles)
}
