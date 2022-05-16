extends Node2D


export(PackedScene) var tetromino_scene: PackedScene
export(PackedScene) var cell_scene: PackedScene
export var field_width: int = 10
export var field_height: int = 20
export var normal_gravity: float = 1
export var soft_drop_gravity: float = 4
export var visible_next_pieces: int = 6
var active_tetromino: Tetromino = null
var ghost_tetromino: Tetromino = null
var cell_size: int = 0
var cell_map: Array = []
var next_tetrominoes: Array = []
var time_since_last_fall: float = 0
var current_gravity: float = normal_gravity

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
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if Input.is_action_just_pressed("rotate_cw"):
		rotate_tetromino("CW")
	elif Input.is_action_just_pressed("rotate_ccw"):
		rotate_tetromino("CCW")
	elif Input.is_action_just_pressed("left_shift"):
		shift_tetromino(-1)
	elif Input.is_action_just_pressed("right_shift"):
		shift_tetromino(1)
	elif Input.is_action_just_pressed("hard_drop"):
		position_tetromino_at_bottom(active_tetromino)
		time_since_last_fall = 0
	elif Input.is_action_just_pressed("change_tetromino"):
		destroy_tetromino()
		spawn_tetromino()
	if Input.is_action_just_pressed("soft_drop"):
		current_gravity = soft_drop_gravity
	elif Input.is_action_just_released("soft_drop"):
		current_gravity = normal_gravity

	time_since_last_fall += delta
	var wait_time = 1 / current_gravity
	if time_since_last_fall > wait_time:
		tetromino_fall()
		time_since_last_fall = 0

func _draw():
	var border_width = 4
	var border_color = Color.gray
	draw_rect(Rect2(-border_width, -border_width, border_width, field_height * cell_size + border_width * 2), border_color)
	draw_rect(Rect2(0, -border_width, field_width * cell_size + border_width, border_width), border_color)
	draw_rect(Rect2(0, field_height * cell_size, field_width * cell_size + border_width, border_width), border_color)
	draw_rect(Rect2(field_width * cell_size, 0, border_width, field_height * cell_size), border_color)

### Active Tetromino Functions

func spawn_tetromino():
	assert(active_tetromino == null, "There should not be an active tetromino when spawning")
	var next_tetromino = next_tetrominoes.pop_front()
	active_tetromino = next_tetromino
	add_child(active_tetromino)
	var tetromino_distance_to_left = 1.5
	var tetromino_distance_to_top = 1.0 if active_tetromino.block_type == "I" || active_tetromino.block_type == "O" else 1.5
	if active_tetromino.block_type == "I":
		tetromino_distance_to_left = 2
	elif active_tetromino.block_type == "O":
		tetromino_distance_to_left = 1
	var tetromino_distance_to_right = tetromino_distance_to_left
	active_tetromino.cell_position = Vector2(
		tetromino_distance_to_left + int(randf() * (field_width - tetromino_distance_to_left - tetromino_distance_to_right)),
		tetromino_distance_to_top
	)

	if next_tetrominoes.size() < visible_next_pieces:
		restock_next_tetrominoes()
	
	ghost_tetromino = tetromino_scene.instance()
	ghost_tetromino.initialize(cell_size, cell_scene, active_tetromino.block_type, true)
	add_child(ghost_tetromino)
	position_ghost_tetromino()

func restock_next_tetrominoes():
	var tetrominoes_as_types = Tetromino.ALL_TETROMINOES.duplicate()
	tetrominoes_as_types.shuffle()
	for tetromino_type in tetrominoes_as_types:
		var tetromino = tetromino_scene.instance()
		tetromino.initialize(cell_size, cell_scene, tetromino_type)
		next_tetrominoes.push_back(tetromino)

func position_ghost_tetromino():
	ghost_tetromino.cell_position = active_tetromino.cell_position
	position_tetromino_at_bottom(ghost_tetromino)

func position_tetromino_at_bottom(tetromino: Tetromino):
	while !check_collision(tetromino):
		tetromino.cell_position += Vector2.DOWN
	tetromino.cell_position += Vector2.UP

func shift_tetromino(amount: float):
	var current_position = active_tetromino.cell_position
	active_tetromino.cell_position += Vector2.RIGHT * amount
	if check_collision(active_tetromino):
		active_tetromino.cell_position = current_position
		return
	position_ghost_tetromino()

func rotate_tetromino(dir: String):
	var current_rotation = active_tetromino.rotated_times
	var opposite_dir = "CW" if dir == "CCW" else "CCW"

	# Rotate and check if basic rotation has no collision
	active_tetromino.rotate90(dir)
	var rotation_is_valid = !check_collision(active_tetromino)

	if !rotation_is_valid:
		# Check if wall kick is available and there is no collision with a wall kick
		var kick_data = get_wall_kicks()
		if kick_data != null:
			var available_kicks = kick_data[current_rotation][dir]
			for kick in available_kicks:
				var kick_vec = Vector2(kick[0], kick[1])
				var current_cell_position = active_tetromino.cell_position
				active_tetromino.cell_position += kick_vec
				if !check_collision(active_tetromino):
					rotation_is_valid = true
					break
				active_tetromino.cell_position = current_cell_position

	if rotation_is_valid:
		ghost_tetromino.rotate90(dir)
		position_ghost_tetromino()
		# TODO: Poor man's lock delay, implement this correctly later
		var current_position = active_tetromino.cell_position
		active_tetromino.cell_position += Vector2.DOWN
		if check_collision(active_tetromino):
			time_since_last_fall = 0
		active_tetromino.cell_position = current_position
	else:
		# Undo rotation if basic rotation and all wall kicks collide
		active_tetromino.rotate90(opposite_dir)

func check_collision(tetromino: Tetromino):
	for cell in tetromino.cells:
		if check_collision_cell(tetromino, cell):
			return true
	return false

func check_collision_cell(tetromino: Tetromino, cell: Cell):
	var effective_cell_position = tetromino.cell_position + cell.cell_position
	var effective_position = effective_cell_position
	var cell_rect = Rect2(effective_position - Vector2(0.5, 0.5), Vector2(1, 1))
	if (cell_rect.position.x < 0 || cell_rect.end.x > field_width ||
		cell_rect.position.y < 0 || cell_rect.end.y > field_height):
		return true
	var existing_cell = cell_map[floor(effective_cell_position.y)][floor(effective_cell_position.x)]
	return existing_cell != null

func get_wall_kicks():
	if active_tetromino.block_type == "O":
		return null
	if active_tetromino.block_type == "I":
		return I_WALL_KICK_DATA
	return JLTSZ_WALL_KICK_DATA

func tetromino_fall():
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
		place_tetromino()
		spawn_tetromino()
	else:
		active_tetromino.cell_position += Vector2.DOWN

	position_ghost_tetromino()

func place_tetromino():
	for cell in active_tetromino.cells:
		var position = active_tetromino.cell_position + cell.cell_position
		assert(cell_map[position.y][position.x] == null, "Tetromino should not ever overlap with other cells")
		cell_map[position.y][position.x] = cell
		active_tetromino.remove_child(cell)
		add_child(cell)
		cell.set_cell_position(position)
		cell.initialize_borders_medium()
		cell.update()
	
	# Check for filled lines
	for j in range(field_height):
		var row = cell_map[j]
		# Check if all cells in cell_map[j] are non-null/filled
		var all_filled = true
		for cell in row:
			if cell == null:
				all_filled = false
				break
		# Move all lines above j down one if line is filled
		if all_filled:
			for cell in row:
				cell.queue_free()
			for j_above in range(j - 1, 0, -1):
				for i in range(field_width):
					var cell = cell_map[j_above][i]
					cell_map[j_above + 1][i] = cell
					if cell != null:
						cell.cell_position += Vector2.DOWN
			for top_cell_i in range(field_width):
				cell_map[0][top_cell_i] = null

	# Destroy active_tetromino and ghost_tetromino
	destroy_tetromino()

func destroy_tetromino():
	active_tetromino.queue_free()
	active_tetromino = null
	ghost_tetromino.queue_free()
	ghost_tetromino = null
