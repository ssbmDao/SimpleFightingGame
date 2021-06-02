extends Node2D

var characters
var p1_start_pos = Vector2(300,480)
var p2_start_pos = Vector2(700,480)

func _ready() -> void:
	characters = get_tree().get_nodes_in_group("Characters")
	for c in characters:
		if c.player_number == 1:
			c.global_position = p1_start_pos
		if c.player_number == 2:
			c.global_position = p2_start_pos
			c.scale.x = -1
			c.facing_right = false
