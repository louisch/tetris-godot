extends Node2D

class_name Tetromino

enum State {
	FALLING, SETTLED
}

# Declare member variables here.
var cell_scene: PackedScene
var state = State.FALLING
var block_type: String
var cell_size: int
var cells: Array
const COLORS = {
	"I": Color.cyan,
	"O": Color.yellow,
	"T": Color.purple,
	"S": Color.green,
	"Z": Color.red,
	"J": Color.blue,
	"L": Color.orange,
}
enum ROTATION {
	NONE,
	CW1,
	CW2,
	CW3
}
const ALL_TETROMINOES = ["I", "O", "T", "S", "Z", "J", "L"]
var cell_position: Vector2 setget set_cell_position
var rotated_times: int = ROTATION.NONE setget set_rotation_as
var center_of_rotation: Vector2

func initialize(cell_size_: int, cell_scene_: PackedScene, block_type_: String, is_ghost: bool = false):
	cell_scene = cell_scene_
	cell_size = cell_size_
	initiate_block_type(block_type_, is_ghost)
	set_rotation_as(ROTATION.NONE)

func initiate_block_type(new_block_type: String, is_ghost: bool):
	block_type = new_block_type
	
	# Initialize cells
	for cell in cells:
		cell.queue_free()
	cells = []
	for _i in range(4):
		var new_cell: Cell = cell_scene.instance()
		add_child(new_cell)
		if !is_ghost:
			new_cell.initialize(cell_size, COLORS[block_type])
		else:
			new_cell.initialize(cell_size, Color.transparent, Color.white, 0)
		cells.push_back(new_cell)

func set_rotation_as(rotation: int):
	rotated_times = rotation
	# Match block type
	match block_type:
		"I":
			cells[0].cell_position = Vector2(-1.5, -0.5)
			cells[1].cell_position = Vector2(-0.5, -0.5)
			cells[2].cell_position = Vector2(0.5, -0.5)
			cells[3].cell_position = Vector2(1.5, -0.5)
		"J":
			cells[0].cell_position = Vector2(-1, -1)
			cells[1].cell_position = Vector2(-1, 0)
			cells[2].cell_position = Vector2(0, 0)
			cells[3].cell_position = Vector2(1, 0)
		"L":
			cells[0].cell_position = Vector2(-1, 0)
			cells[1].cell_position = Vector2(0, 0)
			cells[2].cell_position = Vector2(1, 0)
			cells[3].cell_position = Vector2(1, -1)
		"O":
			cells[0].cell_position = Vector2(-0.5, -0.5)
			cells[1].cell_position = Vector2(-0.5, 0.5)
			cells[2].cell_position = Vector2(0.5, 0.5)
			cells[3].cell_position = Vector2(0.5, -0.5)
		"T":
			cells[0].cell_position = Vector2(-1, 0)
			cells[1].cell_position = Vector2(0, 0)
			cells[2].cell_position = Vector2(0, -1)
			cells[3].cell_position = Vector2(1, 0)
		"S":
			cells[0].cell_position = Vector2(-1, 0)
			cells[1].cell_position = Vector2(0, 0)
			cells[2].cell_position = Vector2(0, -1)
			cells[3].cell_position = Vector2(1, -1)
		"Z":
			cells[0].cell_position = Vector2(-1, -1)
			cells[1].cell_position = Vector2(0, -1)
			cells[2].cell_position = Vector2(0, 0)
			cells[3].cell_position = Vector2(1, 0)
	
	if rotation != ROTATION.NONE:
		for cell in cells:
			var rotation_amount = rotation * PI / 2
			cell.cell_position = cell.cell_position.rotated(rotation_amount)
	
	# Set Cell Borders
	for cell in cells:
		cell.initialize_borders()
		for other_cell in cells:
			if cell == other_cell:
				continue
			var vec_between = other_cell.cell_position - cell.cell_position
			if vec_between.distance_squared_to(Vector2.ZERO) > 1.1:
				continue
			if vec_between.x > 0.1:
				cell.borders[Cell.Direction.RIGHT] = Cell.Border.THIN
			elif vec_between.x < -0.1:
				cell.borders[Cell.Direction.LEFT] = Cell.Border.THIN
			elif vec_between.y > 0.1:
				cell.borders[Cell.Direction.DOWN] = Cell.Border.THIN
			else:
				cell.borders[Cell.Direction.UP] = Cell.Border.THIN
		cell.update()

func set_cell_position(new_cell_position: Vector2):
	cell_position = new_cell_position
	position = Vector2(
		cell_size * cell_position.x,
		cell_size * cell_position.y
	)

func translate_cell_position_x(delta_x: float):
	set_cell_position(cell_position + Vector2(delta_x, 0))

func translate_cell_position_y(delta_y: float):
	set_cell_position(cell_position + Vector2(0, delta_y))

func rotate90(dir):
	if dir == "CW":
		set_rotation_as((rotated_times + 1) % 4)
	else:
		set_rotation_as((rotated_times - 1) % 4)
