extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var num = 16
	if num & (1 << (1 - 1)):
		print("Odd")
	else:
		print("Even")
	pass # Replace with function body.

17
10001
00010
if n & (1 << (1-1))
if n & (1 << 1)
00010
10001

10001
00001
