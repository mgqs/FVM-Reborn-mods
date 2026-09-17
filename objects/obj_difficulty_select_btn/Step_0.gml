if (point_in_rectangle(mouse_x, mouse_y, x-hitbox_width/2, y-hitbox_height/2, x+hitbox_width/2, y+hitbox_height/2)) {
    image_index = 1
} else {
    image_index = 0
}
state = global.difficulty