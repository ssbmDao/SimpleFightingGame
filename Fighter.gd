extends KinematicBody2D

export var WALK_SPEED = 100
export var DASH_SPEED = 500
export var player_number : int
var movement = Vector2.ZERO #2D Vector
var control_inputs = {}
var input_log = []
export var facing_right = true
onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var this_name = self.name

enum STATE {ATTACK, GUARD, FREE}
enum INPUTS {P1_LEFT=1,P1_RIGHT=2,P1_PUNCH=3,P1_KICK=4,P1_BLOCK=5,
	P2_LEFT=6,P2_RIGHT=7,P2_PUNCH=8,P2_KICK=9,P2_BLOCK=10}
var state
var replay_inputs = []
var input_map = ["p1_left", "p1_right", "p1_punch", "p1_kick", "p1_block", 
	"p2_left", "p2_right", "p2_punch", "p2_kick", "p2_block"]

# Called when the node enters the scene tree for the first time.
func _ready():
	state = STATE.FREE
	
func player_input_new():
	var index = 0
	var current_inputs = 0
	for input in input_map:
		if(Input.is_action_pressed(input)):
			current_inputs = current_inputs + pow(2,index)
		index+=1
	replay_inputs.append(current_inputs)
	return int(current_inputs)
		
func interpret_input(value,input):
	# Value is current input total
	# Input is user input being checked for
	if value & (1 << (input - 1)):
		return true
	else:
		return false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#player_input()
	var current_inputs = player_input_new()
	player_movement(current_inputs)
	#animates_player()
	movement = move_and_slide(movement)

func animates_player():
	if state == STATE.FREE:
		if movement != Vector2.ZERO:
			if (!facing_right && control_inputs.left) || (facing_right && control_inputs.right):
				anim.play("walk")
			else:
				anim.play_backwards("walk")
		else:
			# Play idle animation
			anim.play("idle")
		if control_inputs.punch:
			state = STATE.ATTACK
			anim.play("punch")
			yield(anim, "animation_finished")
			state = STATE.FREE
		if control_inputs.kick:
			state = STATE.ATTACK
			anim.play("kick")
			yield(anim, "animation_finished")
			state = STATE.FREE
		if control_inputs.block:
			state = STATE.GUARD
			anim.play("block")
	if state == STATE.GUARD:
		if control_inputs.block_release:
			anim.play("idle")
			state = STATE.FREE

func player_movement(current_inputs):
	if player_number == 1:
		if state == STATE.FREE:
			if interpret_input(current_inputs,INPUTS.P1_LEFT) && interpret_input(current_inputs,INPUTS.P1_RIGHT):
				movement.x = 0
			elif interpret_input(current_inputs,INPUTS.P1_RIGHT):
				movement.x = WALK_SPEED
			elif interpret_input(current_inputs,INPUTS.P1_LEFT):
				movement.x = -WALK_SPEED
			else:
				movement.x = 0
		else:
			movement.x = 0
	elif player_number == 2:
		if state == STATE.FREE:
			if interpret_input(current_inputs,INPUTS.P2_LEFT) && interpret_input(current_inputs,INPUTS.P2_RIGHT):
				movement.x = 0
			elif interpret_input(current_inputs,INPUTS.P2_RIGHT):
				movement.x = WALK_SPEED
			elif interpret_input(current_inputs,INPUTS.P2_LEFT):
				movement.x = -WALK_SPEED
			else:
				movement.x = 0
		else:
			movement.x = 0
	else:
		print("Error in Player Movement")


func _on_PunchHitBox_area_entered(area: Area2D) -> void:
	if area.get_parent().name == this_name:
		return
	if area.name == "BlockBox":
		print("Hit Block")
	if area.name == "HurtBox":
		print("Hit Character")
	if area.name == "PunchHitBox":
		print("clank")


func _on_KickHitBox_area_entered(area: Area2D) -> void:
	if area.get_parent().name == this_name:
		return
	if area.name == "BlockHitBox":
		print("Hit Block")
	if area.name == "HurtBox":
		print("Hit Character")
	if area.name == "KickHitBox":
		print("clank")

# To share the same code for each player we have this function to determine
# to determine which inputs need to be read
# Legacy Code
func player_input():
	match player_number:
		1:
			control_inputs = {
				"left": Input.is_action_pressed("p1_left"),
				"right": Input.is_action_pressed("p1_right"),
				"punch": Input.is_action_just_pressed("p1_punch"),
				"kick": Input.is_action_just_pressed("p1_kick"),
				"block": Input.is_action_pressed("p1_block"),
				"block_release": Input.is_action_just_released("p1_block")
				
			}
		2:
			control_inputs = {
				"left": Input.is_action_pressed("p2_left"),
				"right": Input.is_action_pressed("p2_right"),
				"punch": Input.is_action_just_pressed("p2_punch"),
				"kick": Input.is_action_just_pressed("p2_kick"),
				"block": Input.is_action_pressed("p2_block"),
				"block_release": Input.is_action_just_released("p2_block")
			}
		_:
			print("No player number entered. You sure you're in the right scene?")
			control_inputs = {
				"left": Input.is_action_pressed("p1_left"),
				"right": Input.is_action_pressed("p1_right"),
				"punch": Input.is_action_just_pressed("p1_punch"),
				"kick": Input.is_action_just_pressed("p1_kick"),
				"block": Input.is_action_pressed("p1_block"),
				"block_release": Input.is_action_just_released("p1_block")
			}
	#player_movement()
