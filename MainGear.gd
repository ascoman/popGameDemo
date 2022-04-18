extends StaticBody2D

export (float) var ROTATION_SPEED = 1.5
onready var ship = $Ship
onready var bigGear = get_tree().get_root().find_node("big_gear1", true, false)
var rotation_Direction

func get_input():
	rotation_Direction = 0.0
	if Input.is_action_pressed('ui_up') or Input.is_action_pressed('ui_right'):
		rotation_Direction -= 1.0
	elif Input.is_action_pressed('ui_down') or Input.is_action_pressed('ui_left'):
		rotation_Direction += 1.0

func _physics_process(delta):
	if ship.can_move:
		get_input()
		if ship.global_rotation_degrees-rotation_Direction >= -50 \
		or ship.global_rotation_degrees-rotation_Direction <= -51:
			var newRotation = rotation_Direction * ROTATION_SPEED * delta
			rotation += newRotation
			bigGear.rotate_gear(rotation_Direction, delta)
