extends Node2D


# Declare member variables here. Examples:
export var game_speed: int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	resize_window()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	pass

func resize_window():
	var screen_size = get_viewport_rect().size
	var field_aspect = float($Field.field_width) / float($Field.field_height)
	var screen_aspect = float(screen_size.x) / float(screen_size.y)
	var cell_size = (screen_size.y if screen_aspect > field_aspect else screen_size.x) / ($Field.field_height + 2)
	var field_top = cell_size
	var field_left = cell_size
	$Field.position = Vector2(field_left, field_top)
	$Field.initialize(cell_size)
	$Field.spawn_tetromino()
