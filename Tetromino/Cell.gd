extends Node2D

class_name Cell

enum Border {
	THIN,
	THICK
}
enum Direction {
	UP, DOWN, LEFT, RIGHT
}
const BORDER_THICK_FACTOR: float = 0.1
const BORDER_THIN_FACTOR: float = 0.025

var cell_size: int = 50
var bg_color: Color = Color.white
var borders = {
	Direction.UP: Border.THICK,
	Direction.DOWN: Border.THICK,
	Direction.LEFT: Border.THICK,
	Direction.RIGHT: Border.THICK,
}
var cell_position: Vector2 setget set_cell_position

func initialize(cell_size_: int, bg_color_: Color):
	cell_size = cell_size_
	bg_color = bg_color_
	initialize_borders()
	update()

func set_cell_position(new_cell_position: Vector2):
	cell_position = new_cell_position
	position = cell_position * cell_size

func opposite_direction(direction: int):
	match direction:
		Direction.UP:
			return Direction.DOWN
		Direction.DOWN:
			return Direction.UP
		Direction.LEFT:
			return Direction.RIGHT
	return Direction.LEFT

func direction_to_vec(direction: int):
	match direction:
		Direction.UP:
			return Vector2.UP
		Direction.DOWN:
			return Vector2.DOWN
		Direction.LEFT:
			return Vector2.LEFT
	return Vector2.RIGHT

func initialize_borders():
	borders = {
		Direction.UP: Border.THICK,
		Direction.DOWN: Border.THICK,
		Direction.LEFT: Border.THICK,
		Direction.RIGHT: Border.THICK,
	}

func add_adjacent(adjacent_cell: Cell, direction: int):
	var opposite_dir = opposite_direction(direction)
	borders[direction] = Border.THIN
	adjacent_cell.borders[opposite_dir] = Border.THIN
	adjacent_cell.position = position + cell_size * direction_to_vec(direction)

func _draw():
	var thick_border_width = int(max(cell_size * BORDER_THICK_FACTOR, 1))
	var thin_border_width = int(max(cell_size * BORDER_THIN_FACTOR, 1))
	var origin_x = -cell_size / 2
	var origin_y = -cell_size / 2
	var up_border_width = thin_border_width if borders[Direction.UP] == Border.THIN else thick_border_width
	var left_border_width = thin_border_width if borders[Direction.LEFT] == Border.THIN else thick_border_width
	var down_origin_y = origin_y + cell_size - thick_border_width
	var down_border_width = thick_border_width
	if borders[Direction.DOWN] == Border.THIN:
		down_origin_y = origin_y + cell_size - thin_border_width
		down_border_width = thin_border_width
	var right_origin_x = origin_x + cell_size - thick_border_width
	var right_border_width = thick_border_width
	if borders[Direction.RIGHT] == Border.THIN:
		right_origin_x = origin_x + cell_size - thin_border_width
		right_border_width = thin_border_width

	draw_rect(Rect2(origin_x, origin_y, cell_size, up_border_width), Color.black)
	draw_rect(Rect2(origin_x, origin_y, left_border_width, cell_size), Color.black)
	draw_rect(Rect2(origin_x, down_origin_y, cell_size, down_border_width), Color.black)
	draw_rect(Rect2(right_origin_x, origin_y, right_border_width, cell_size), Color.black)

	var bg_origin_x = origin_x + left_border_width
	var bg_origin_y = origin_y + up_border_width
	var bg_width = cell_size - left_border_width - right_border_width
	var bg_height = cell_size - up_border_width - down_border_width
	draw_rect(Rect2(bg_origin_x, bg_origin_y, bg_width, bg_height), bg_color)