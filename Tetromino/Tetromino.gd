extends Area2D

class_name Tetromino

enum State {
	FALLING, SETTLED
}

# Declare member variables here.
var cell_scene: PackedScene = preload("res://Tetromino/Cell.tscn")
var state = State.FALLING
var block_type: String
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

func initialize(new_cell_size: int):
	# Set Cell Size
	cell_size = new_cell_size

	# Set block type randomly
	var all_tetrominoes = TetrominoUtils.all_tetrominoes()
	block_type = all_tetrominoes[int(randf() * all_tetrominoes.size())]

	# Initialize cells
	cells = []
	for _i in range(4):
		var new_cell: Cell = cell_scene.instance()
		add_child(new_cell)
		new_cell.initialize(cell_size, COLORS[block_type])
		cells.push_back(new_cell)
	match block_type:
		"I":
			cells[1].attach(cells[0], "LEFT")
			cells[1].attach(cells[2], "RIGHT")
			cells[2].attach(cells[3], "RIGHT")
		"J":
			cells[1].attach(cells[0], "UP")
			cells[1].attach(cells[2], "DOWN")
			cells[2].attach(cells[3], "LEFT")
		"L":
			cells[1].attach(cells[0], "UP")
			cells[1].attach(cells[2], "DOWN")
			cells[2].attach(cells[3], "RIGHT")
		"O":
			cells[0].attach(cells[1], "DOWN")
			cells[1].attach(cells[2], "RIGHT")
			cells[2].attach(cells[3], "UP")
			cells[3].attach(cells[0], "LEFT")
		"T":
			cells[1].attach(cells[0], "LEFT")
			cells[1].attach(cells[2], "UP")
			cells[1].attach(cells[3], "RIGHT")
		"S":
			cells[1].attach(cells[0], "LEFT")
			cells[1].attach(cells[2], "DOWN")
			cells[2].attach(cells[3], "RIGHT")
		"Z":
			cells[1].attach(cells[0], "LEFT")
			cells[1].attach(cells[2], "UP")
			cells[2].attach(cells[3], "RIGHT")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

func rotate90():
	var rotation_amount = PI / 2
	if state == State.FALLING:
		if block_type == "I" && rotation > 0:
			rotate_about_center(-rotation_amount)
		elif block_type != "O":
			rotate_about_center(rotation_amount)

func rotate_about_center(rotation_amount: float):
	var center_position = position + Vector2(cell_size / 2.0, cell_size / 2.0).rotated(rotation)
	rotate(rotation_amount)
	var new_center_position = position + Vector2(cell_size / 2.0, cell_size / 2.0).rotated(rotation)
	print_debug(center_position, new_center_position, center_position - new_center_position)
	translate(center_position - new_center_position)