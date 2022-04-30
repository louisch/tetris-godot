extends Node2D

class_name Tetromino

enum State {
	FALLING, SETTLED
}

# Declare member variables here.
export var cell_scene: PackedScene
var state = State.FALLING
export var block_type: String setget set_block_type
var cell_size: int
var cells: Array
const COLORS = {
	"I": Color.aqua,
	"J": Color.darkblue,
	"L": Color.orange,
	"O": Color.yellow,
	"T": Color.magenta,
	"S": Color.green,
	"Z": Color.red,
}
var cell_position: Vector2 setget set_cell_position
var rotated_times: int = 0

func initialize(new_cell_size: int, cell_scene_: PackedScene):
	cell_scene = cell_scene_
	# Set Cell Size
	cell_size = new_cell_size

	# Set block type randomly
	var all_tetrominoes = TetrominoUtils.all_tetrominoes()
	var new_block_type = all_tetrominoes[int(randf() * all_tetrominoes.size())]
	set_block_type(new_block_type)

func set_block_type(new_block_type: String):
	block_type = new_block_type
	
	# Initialize cells
	for cell in cells:
		cell.queue_free()
	cells = []
	for _i in range(4):
		var new_cell: Cell = cell_scene.instance()
		add_child(new_cell)
		new_cell.initialize(cell_size, COLORS[block_type])
		cells.push_back(new_cell)
	match block_type:
		"I":
			cells[0].add_adjacent(cells[1], Cell.Direction.LEFT)
			cells[0].add_adjacent(cells[2], Cell.Direction.RIGHT)
			cells[2].add_adjacent(cells[3], Cell.Direction.RIGHT)
		"J":
			cells[0].add_adjacent(cells[1], Cell.Direction.UP)
			cells[0].add_adjacent(cells[2], Cell.Direction.DOWN)
			cells[2].add_adjacent(cells[3], Cell.Direction.LEFT)
		"L":
			cells[0].add_adjacent(cells[1], Cell.Direction.UP)
			cells[0].add_adjacent(cells[2], Cell.Direction.DOWN)
			cells[2].add_adjacent(cells[3], Cell.Direction.RIGHT)
		"O":
			cells[0].add_adjacent(cells[1], Cell.Direction.DOWN)
			cells[1].add_adjacent(cells[2], Cell.Direction.RIGHT)
			cells[2].add_adjacent(cells[3], Cell.Direction.UP)
			cells[0].borders[Cell.Direction.RIGHT] = Cell.Border.THIN
			cells[3].borders[Cell.Direction.LEFT] = Cell.Border.THIN
		"T":
			cells[0].add_adjacent(cells[1], Cell.Direction.LEFT)
			cells[0].add_adjacent(cells[2], Cell.Direction.UP)
			cells[0].add_adjacent(cells[3], Cell.Direction.RIGHT)
		"S":
			cells[0].add_adjacent(cells[1], Cell.Direction.LEFT)
			cells[0].add_adjacent(cells[2], Cell.Direction.DOWN)
			cells[2].add_adjacent(cells[3], Cell.Direction.RIGHT)
		"Z":
			cells[0].add_adjacent(cells[1], Cell.Direction.LEFT)
			cells[0].add_adjacent(cells[2], Cell.Direction.UP)
			cells[2].add_adjacent(cells[3], Cell.Direction.RIGHT)

func set_cell_position(new_cell_position):
	cell_position = new_cell_position
	position = Vector2(
		cell_size * cell_position.x,
		cell_size * cell_position.y
	)

func set_cell_position_at_top(cell_position_x):
	var highest_cell = cells[0]
	for cell in cells:
		if cell.cell_position.y < highest_cell.cell_position.y:
			highest_cell = cell
	var cell_position_y = -highest_cell.cell_position.y
	set_cell_position(Vector2(
		cell_position_x,
		cell_position_y
	))

func rotate90():
	if state == State.FALLING:
		if block_type == "I" && rotated_times > 0:
			rotate90_ccw_about_center()
		elif block_type != "O":
			rotate90_cw_about_center()

func rotate90_cw_about_center():
	for cell in cells:
		cell.rotate_about_origin_cw()
	rotated_times = (rotated_times + 1) % 4

func rotate90_ccw_about_center():
	for cell in cells:
		cell.rotate_about_origin_ccw()
	rotated_times -= 1
	if rotated_times < 0:
		rotated_times += 4
