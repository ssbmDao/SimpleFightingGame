extends KinematicBody2D

export var WALK_SPEED = 100
export var DASH_SPEED = 500
var movement = Vector2.ZERO
onready var anim = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("p1_right"):
		movement.x = WALK_SPEED
	elif Input.is_action_pressed("p1_left"):
		movement.x = -1*WALK_SPEED
	else:
		movement.x = 0
	animates_player()
	movement = move_and_slide(movement)
	
func animates_player():
	if movement != Vector2.ZERO:
		# Play walk animation
		anim.play("walk_forward")
	else:
		# Play idle animation
		anim.play("idle")