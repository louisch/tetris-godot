extends Node2D


export(PackedScene) var tetromino_scene: PackedScene
export(PackedScene) var cell_scene: PackedScene
export var field_width: int = 10
export var field_height: int = 20
export var fall_speed: float = 1
export var visible_next_pieces: int = 6
var active_tetromino: Tetromino
var cell_size: int
var cell_map: Array = []
var next_tetrominoes: Array = []

const I_WALL_KICK_DATA = [
	{
		"CCW": [[-1, 0], [2, 0], [-1, -2], [2, 1]],
		"CW": [[-2, 0], [1, 0], [-2, 1], [1, -2]],
	},
	{
		"CCW": [[2, 0], [-1, 0], [2, -1], [-1, 2]],
		"CW": [[-1, 0], [2, 0], [-1, -2], [2, 1]],
	},
	{
		"CCW": [[1, 0], [-2, 0], [1, 2], [-2, -1]],
		"CW": [[2, 0], [-1, 0], [2, -1], [-1, 2]],
	},
	{
		"CCW": [[-2, 0], [1, 0], [-2, 1], [1, -2]],
		"CW": [[1, 0], [-2, 0], [1, 2], [-2, -1]],
	},
]
const JLTSZ_WALL_KICK_DATA = [
	{
		"CCW": [[1, 0], [1, -1], [0, 2], [1, 2]],
		"CW": [[-1, 0], [-1, -1], [0, 2], [-1, 2]],
	},
	{
		"CCW": [[1, 0], [1, 1], [0, -2], [1, -2]],
		"CW": [[1, 0], [1, 1], [0, -2], [1, -2]],
	},
	{
		"CCW": [[-1, 0], [-1, -1], [0, 2], [-1, 2]],
		"CW": [[1, 0], [1, -1], [0, 2], [1, 2]],
	},
	{
		"CCW": [[-1, 0], [-1, 1], [0, -2], [-1, -2]],
		"CW": [[-1, 0], [-1, 1], [0, -2], [-1, -2]],
	},
]

func initialize(new_cell_size: int):
	cell_size = new_cell_size
	for j in range(field_height):
		cell_map.push_back([])
		for _i in range(field_width):
			cell_map[j].push_back(null)
	restock_next_tetrominoes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if Input.is_action_just_pressed("rotate_cw"):
		rotate_tetromino("CW")
	elif Input.is_action_just_pressed("rotate_ccw"):
		rotate_tetromino("CCW")
	elif Input.is_action_just_pressed("left_shift"):
		shift_tetromino(-1)
	elif Input.is_action_just_pressed("right_shift"):
		shift_tetromino(1)
	elif Input.is_action_just_pressed("change_tetromino"):
		active_tetromino.queue_free()
		spawn_tetromino()

# Called once every "tick", which gets faster with game speed
func _on_tick():
	tick_tetromino()


### Active Tetromino Functions

func spawn_tetromino():
	var next_tetromino = next_tetrominoes.pop_front()
	active_tetromino = next_tetromino
	add_child(active_tetromino)
	var tetromino_distance_to_left = 1.5
	if active_tetromino.block_type == "I":
		tetromino_distance_to_left = 2
	elif active_tetromino.block_type == "O":
		tetromino_distance_to_left = 1
	var tetromino_distance_to_right = tetromino_distance_to_left
	var cell_position = Vector2(
		tetromino_distance_to_left + int(randf() * (field_width - tetromino_distance_to_left - tetromino_distance_to_right)),
		0
	)
	if active_tetromino.block_type == "I" || active_tetromino.block_type == "O":
		cell_position = Vector2(
			cell_position.x,
			1
		)
	else:
		cell_position = Vector2(
			cell_position.x + 0.5,
			1.5
		)
	active_tetromino.set_cell_position(cell_position)

	if next_tetrominoes.size() < visible_next_pieces:
		restock_next_tetrominoes()

func restock_next_tetrominoes():
	var tetrominoes = Tetromino.ALL_TETROMINOES.duplicate()
	tetrominoes.shuffle()
	for tetromino_type in tetrominoes:
		var tetromino = tetromino_scene.instance()
		tetromino.initialize(cell_size, cell_scene)
		next_tetrominoes.push_back(tetromino)

func shift_tetromino(amount: float):
	active_tetromino.cell_position += Vector2.RIGHT * amount

func rotate_tetromino(dir: String):
	var current_rotation = active_tetromino.rotated_times
	var opposite_dir = "CW" if dir == "CCW" else "CCW"

	# Rotate and check if basic rotation has no collision
	active_tetromino.rotate90(dir)
	if !check_collision():
		return

	# Check if wall kick is available and there is no collision with a wall kick
	var kick_data = get_wall_kicks()
	if kick_data != null:
		var available_kicks = kick_data[current_rotation][dir]
		for kick in available_kicks:
			var kick_vec = Vector2(kick[0], kick[1])
			var current_cell_position = active_tetromino.cell_position
			active_tetromino.cell_position += kick_vec
			if !check_collision():
				return
			active_tetromino.cell_position = current_cell_position

	# Undo rotation if basic rotation and all wall kicks collide
	active_tetromino.rotate90(opposite_dir)

func check_collision():
	for cell in active_tetromino.cells:
		if check_collision_cell(cell):
			return true
	return false

func check_collision_cell(cell: Cell):
	var effective_cell_position = active_tetromino.cell_position + cell.cell_position
	var effective_position = effective_cell_position
	var cell_rect = Rect2(effective_position - Vector2(0.5, 0.5), Vector2(1, 1))
	if (cell_rect.position.x < 0 || cell_rect.end.x >= field_width ||
		cell_rect.position.y < 0 || cell_rect.end.y >= field_height):
		return true
	var existing_cell = cell_map[floor(effective_cell_position.y)][floor(effective_cell_position.x)]
	return existing_cell != null

func get_wall_kicks():
	if active_tetromino.block_type == "O":
		return null
	if active_tetromino.block_type == "I":
		return I_WALL_KICK_DATA
	return JLTSZ_WALL_KICK_DATA

func tick_tetromino():
	var has_space_to_fall = true

	for cell in active_tetromino.cells:
		var position_below = active_tetromino.cell_position + cell.cell_position + Vector2.DOWN
		var has_sibling_cell_below = false
		for other_cell in active_tetromino.cells:
			if position_below == other_cell.position:
				has_sibling_cell_below = true
				break
		if has_sibling_cell_below:
			continue
		
		if position_below.y > field_height || cell_map[position_below.y][position_below.x] != null:
			has_space_to_fall = false
			break

	if !has_space_to_fall:
		# place tetromino
		pass
	else:
		active_tetromino.set_cell_position(active_tetromino.cell_position + Vector2.DOWN)

