extends KinematicBody2D

export var WALK_SPEED = 100
export var DASH_SPEED = 35
export var player_number : int
export var dash_cooldown_time = 1
var movement = Vector2.ZERO #2D Vector
var control_inputs = {}
export var facing_right = true
onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var this_name = self.name

enum STATE {ATTACK, GUARD, FREE, DASH}
var state
var dash_right = 0
var dash_left = 0
var dash_direction
var dash_on_cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	state = STATE.FREE

# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	player_input()
	animates_player()
	

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


func player_movement():
	if state == STATE.FREE:
		if control_inputs.right && control_inputs.left:
			movement.x = 0
		elif control_inputs.right || control_inputs.right_step:
			if control_inputs.right_step:
				for child in get_children():
					if child.name == "dash_left_timer":
						print("found left timer")
						_on_dash_timer_timeout("left", child)
				match dash_right:
					0:
						dash_right = 1
						dash_direction = "right"
						var dash_right_timer = Timer.new()
						dash_right_timer.set_wait_time(.2)
						dash_right_timer.connect("timeout", self, "_on_dash_timer_timeout", [dash_direction, dash_right_timer])
						add_child(dash_right_timer)
						dash_right_timer.start()
						dash_right_timer.name = "dash_right_timer"
					1:
						if !dash_on_cooldown:
							state = STATE.DASH
						dash_right = 0
					_:
						return
			movement.x = WALK_SPEED
		elif control_inputs.left || control_inputs.left_step:
			if control_inputs.left_step:
				for child in get_children():
					if child.name == "dash_right_timer":
						print("found right timer")
						_on_dash_timer_timeout("right", child)
				match dash_left:
					0:
						dash_left = 1
						dash_direction = "left"
						var dash_left_timer = Timer.new()
						dash_left_timer.set_wait_time(.2)
						dash_left_timer.connect("timeout", self, "_on_dash_timer_timeout", [dash_direction, dash_left_timer])
						add_child(dash_left_timer)
						dash_left_timer.start()
						dash_left_timer.name = "dash_left_timer"
					1:
						if !dash_on_cooldown:
							state = STATE.DASH
						dash_left = 0
					_:
						return
			movement.x = -WALK_SPEED
		else:
			movement.x = 0
	else:
		movement.x = 0
	
	if state == STATE.DASH:
		dash_on_cooldown = true
		var dash_cooldown_timer = Timer.new()
		dash_cooldown_timer.connect("timeout", self, "_on_dash_cooldown_timer_timeout", [dash_cooldown_timer])
		dash_cooldown_timer.name = "DashCooldownTimer"
		dash_cooldown_timer.set_wait_time(dash_cooldown_time)
		add_child(dash_cooldown_timer)
		dash_cooldown_timer.start()
		var d
		match dash_direction:
			"right":
				d = DASH_SPEED
				
			"left":
				d = -DASH_SPEED
		var tween = Tween.new()
		var cur_pos = position
		tween.interpolate_property(self, "position", cur_pos, Vector2(cur_pos.x + d, position.y), .05, Tween.TRANS_LINEAR,Tween.EASE_OUT)
		add_child(tween)
		tween.start()
		yield(tween, "tween_completed")
		state = STATE.FREE
	
	if state != STATE.ATTACK:
		movement = move_and_slide(movement)
		#state = STATE.FREE

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
		print("Hit Low on Block")
	if area.name == "HurtBox":
		print("Hit Character")
	if area.name == "KickHitBox":
		print("clank")

func _on_dash_timer_timeout(direction, timer_node):
	if state != STATE.ATTACK:
		timer_node.queue_free()
		if direction == "right":
			dash_right = 0
		elif direction == "left":
			dash_left = 0

func _on_dash_cooldown_timer_timeout(timer_node):
	timer_node.queue_free()
	dash_on_cooldown = false

# To share the same code for each player we have this function to determine
# to determine which inputs need to be read
func player_input():
	match player_number:
		1:
			control_inputs = {
				"left": Input.is_action_pressed("p1_left"),
				"left_step": Input.is_action_just_pressed("p1_left"),
				"right": Input.is_action_pressed("p1_right"),
				"right_step": Input.is_action_just_pressed("p1_right"),
				"punch": Input.is_action_just_pressed("p1_punch"),
				"kick": Input.is_action_just_pressed("p1_kick"),
				"block": Input.is_action_pressed("p1_block"),
				"block_release": Input.is_action_just_released("p1_block")
			}
		2:
			control_inputs = {
				"left": Input.is_action_pressed("p2_left"),
				"left_step": Input.is_action_just_pressed("p2_left"),
				"right": Input.is_action_pressed("p2_right"),
				"right_step": Input.is_action_just_pressed("p2_right"),
				"punch": Input.is_action_just_pressed("p2_punch"),
				"kick": Input.is_action_just_pressed("p2_kick"),
				"block": Input.is_action_pressed("p2_block"),
				"block_release": Input.is_action_just_released("p2_block")
			}
		_:
			print("No player number entered. You sure you're in the right scene?")
			control_inputs = {
				"left_step": Input.is_action_just_pressed("p1_left"),
				"right": Input.is_action_pressed("p1_right"),
				"right_step": Input.is_action_just_pressed("p1_right"),
				"punch": Input.is_action_just_pressed("p1_punch"),
				"kick": Input.is_action_just_pressed("p1_kick"),
				"block": Input.is_action_pressed("p1_block"),
				"block_release": Input.is_action_just_released("p1_block")
			}
	player_movement()

