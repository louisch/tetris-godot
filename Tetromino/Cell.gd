extends Node2D

class_name Cell

var neighbors = {
	"UP": null,
	"DOWN": null,
	"LEFT": null,
	"RIGHT": null,
}
var x = 0
var y = 0
var cell_size: int = 1
var bg_color: Color = Color.black
const BORDER_FACTOR: float = 0.1
const INSIDE_FACTOR: float = 0.025

func initialize(cell_size_: int, bg_color_: Color):
	cell_size = cell_size_
	bg_color = bg_color_

func opposite_direction(direction):
	match direction:
		"UP":
			return "DOWN"
		"DOWN":
			return "UP"
		"LEFT":
			return "RIGHT"
	return "LEFT"

func create_neighbor(direction):
	var neighbor = get_script().new()
	neighbor.x = self.x
	neighbor.y = self.y
	match direction:
		"UP":
			neighbor.y -= 1
		"DOWN":
			neighbor.y += 1
		"LEFT":
			neighbor.x -= 1
		"RIGHT":
			neighbor.x += 1
	self.neighbors[direction] = neighbor
	neighbor.neighbors[opposite_direction(direction)] = self
	return neighbor

func create_neighbors(directions):
	var createdNeighbors = []
	for direction in directions:
		createdNeighbors.push_back(create_neighbor(direction))
	return createdNeighbors[0] if !createdNeighbors.empty() else null

func attach(other, direction):
	neighbors[direction] = other
	other.neighbors[opposite_direction(direction)] = self
	other.x = x
	other.y = y
	match direction:
		"UP":
			other.y -= 1
		"DOWN":
			other.y += 1
		"LEFT":
			other.x -= 1
		"RIGHT":
			other.x += 1

func _draw():
	var border_thickness = int(max(cell_size * BORDER_FACTOR, 1))
	var inside_thickness = int(max(cell_size * INSIDE_FACTOR, 1))
	var origin_x = x * cell_size
	var origin_y = y * cell_size
	var up_thickness = border_thickness if neighbors["UP"] == null else inside_thickness
	var left_thickness = border_thickness if neighbors["LEFT"] == null else inside_thickness
	var down_origin_y = origin_y + cell_size - border_thickness
	var down_thickness = border_thickness
	if neighbors["DOWN"] != null:
		down_origin_y = origin_y + cell_size - inside_thickness
		down_thickness = inside_thickness
	var right_origin_x = origin_x + cell_size - border_thickness
	var right_thickness = border_thickness
	if neighbors["RIGHT"] != null:
		right_origin_x = origin_x + cell_size - inside_thickness
		right_thickness = inside_thickness

	draw_rect(Rect2(origin_x, origin_y, cell_size, up_thickness), Color.black)
	draw_rect(Rect2(origin_x, origin_y, left_thickness, cell_size), Color.black)
	draw_rect(Rect2(origin_x, down_origin_y, cell_size, down_thickness), Color.black)
	draw_rect(Rect2(right_origin_x, origin_y, right_thickness, cell_size), Color.black)

	var bg_origin_x = origin_x + left_thickness
	var bg_origin_y = origin_y + up_thickness
	var bg_width = cell_size - left_thickness - right_thickness
	var bg_height = cell_size - up_thickness - down_thickness
	draw_rect(Rect2(bg_origin_x, bg_origin_y, bg_width, bg_height), bg_color)