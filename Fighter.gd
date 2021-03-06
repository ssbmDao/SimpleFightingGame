extends KinematicBody2D

export var WALK_SPEED = 100
export var DASH_SPEED = 500
export var player_number : int
var movement = Vector2.ZERO #2D Vector
var control_inputs = {}
var facing = "right"
onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var left_ray = $LeftRayCast
onready var right_ray = $RightRayCast

enum STATE {ATTACK, GUARD, FREE}
var state

# Called when the node enters the scene tree for the first time.
func _ready():
	state = STATE.FREE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_direction()
	player_input()
	animates_player()
	movement = move_and_slide(movement)
	

func animates_player():
	if state == STATE.FREE:
		if movement != Vector2.ZERO:
			if (facing == "left" && control_inputs.left) || (facing == "right" && control_inputs.right):
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
			

# Allows us to generalize characters and not worry about sprite facing.
func look_direction():
	if left_ray.is_colliding() && facing != "left":
		sprite.flip_h = true
		facing = "left"
	if right_ray.is_colliding() && facing != "right":
		sprite.flip_h = true
		facing = "right"


# To share the same code for each player we have this function to determine
# to determine which inputs need to be read
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
			return
	player_movement()

func player_movement():
	if state == STATE.FREE:
		if control_inputs.right && control_inputs.left:
			movement.x = 0
		elif control_inputs.right:
			movement.x = WALK_SPEED
		elif control_inputs.left:
			movement.x = -WALK_SPEED
		else:
			movement.x = 0
	else:
		movement.x = 0
