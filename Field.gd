extends Node2D


export(PackedScene) var tetromino_scene: PackedScene
export(PackedScene) var cell_scene: PackedScene
export var field_width: int = 10
export var field_height: int = 20
var current_tetromino: Tetromino
var cell_size: int
var cell_map: Array = []


func initialize(new_cell_size: int):
	cell_size = new_cell_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if Input.is_action_just_pressed("rotate_block"):
		current_tetromino.rotate90()
	if Input.is_action_just_pressed("change_block"):
		current_tetromino.queue_free()
		spawn_tetromino()

func spawn_tetromino():
	current_tetromino = tetromino_scene.instance()
	current_tetromino.initialize(cell_size, cell_scene)
	add_child(current_tetromino)
	var cell_position_x = int(randf() * field_width)
	current_tetromino.set_cell_position_at_top(cell_position_x)