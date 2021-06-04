extends Node2D

export var debug = true

var characters
var p1
var p2
var p1_start_pos = Vector2(136,230)
var p2_start_pos = Vector2(376,230)
var p1_current_side
var p2_current_side

onready var p2_label = $Player2State

func _ready() -> void:
	characters = get_tree().get_nodes_in_group("Characters")
	for c in characters:
		if c.player_number == 1:
			c.global_position = p1_start_pos
			p1_current_side = "left"
			p1 = c
		if c.player_number == 2:
			c.global_position = p2_start_pos
			c.scale.x = -1
			c.facing_right = false
			p2_current_side = "right"
			p2 = c

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	check_positions()
	if debug:
		update_debug_labels()


func check_positions():
	if p1.position.x < p2.position.x && p1_current_side != "left":
		print("CHANGE PLACES LEFT")
		p1.scale.x = -1
		p1.facing_right = true
		p1_current_side = "left"
		p2.scale.x = -1
		p2.facing_right = false
		p2_current_side = "right"
	if p1.position.x > p2.position.x && p1_current_side != "right":
		print("CHANGE PLACES RIGHT")
		p1.scale.x = -1
		p1.facing_right = false
		p1_current_side = "right"
		p2.scale.x = -1
		p2.facing_right = true
		p2_current_side = "left"
		
	
func update_debug_labels():
	p2_label.set_global_position(Vector2(p2.position.x, p2.position.y - 100))
	p2_label.text = str(p2.state)
