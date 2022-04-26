extends Node

class_name TetrominoUtils

#static func all_cells():
#	var i_cell = Cell.new()
#	i_cell.create_neighbor("RIGHT").create_neighbor("RIGHT")
#	i_cell.create_neighbor("LEFT")
#	var j_cell = Cell.new()
#	j_cell.create_neighbor("UP")
#	j_cell.create_neighbor("DOWN").create_neighbor("LEFT")
#	var l_cell = Cell.new()
#	l_cell.create_neighbor("UP")
#	l_cell.create_neighbor("DOWN").create_neighbor("RIGHT")
#	var o_cell = Cell.new()
#	var o_cell_end = o_cell.create_neighbor("DOWN").create_neighbor("RIGHT").create_neighbor("UP")
#	o_cell.attach(o_cell_end, "RIGHT")
#	var t_cell = Cell.new()
#	t_cell.create_neighbor("RIGHT")
#	t_cell.create_neighbor("UP")
#	t_cell.create_neighbor("LEFT")
#	var s_cell = Cell.new()
#	s_cell.create_neighbor("RIGHT")
#	s_cell.create_neighbor("DOWN").create_neighbor("LEFT")
#	var z_cell = Cell.new()
#	z_cell.create_neighbor("LEFT")
#	z_cell.create_neighbor("DOWN").create_neighbor("RIGHT")
#	return {
#		"I": i_cell,
#		"J": j_cell,
#		"L": l_cell,
#		"O": o_cell,
	#	"T": t_cell,
	#	"S": s_cell,
	#	"Z": z_cell,
	#}

static func all_colors():
	var colors = {
		"I": Color.aqua,
		"J": Color.darkblue,
		"L": Color.orange,
		"O": Color.yellow,
		"T": Color.magenta,
		"S": Color.green,
		"Z": Color.red,
	}
	return colors

static func all_tetrominoes():
	return ["I", "J", "L", "O", "T", "S", "Z"]

static func random_tetromino():
	var all_tetrominoes = all_tetrominoes()
	return all_tetrominoes[int(randf() * all_tetrominoes.size())]