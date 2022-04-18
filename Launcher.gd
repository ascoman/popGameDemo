extends KinematicBody2D

onready var ship = get_tree().get_root().find_node("Ship", true, false)
onready var animationLauncher = $AnimationPlayer

export var rotation_speed = 15.0
export var max_rotation_speed = 85.0
var can_shoot = true
var num_missiles = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getDot(vector1: Vector2, _vector2:Vector2) -> float:
	var n1 = vector1.normalized()
	var n2 = _vector2.normalized()

	var vDot = n1.dot(n2.tangent()) 

	return vDot

func _physics_process(delta):
	var ship_pos = ship.get_global_position()
	var lauch_pos = get_global_position()
	var real_rot = 0

	var player_dir =  ship_pos - lauch_pos
	var angle = polar2cartesian(1.0,rotation)
	var difference : float = player_dir.angle() - angle.angle()
	var dot = getDot(angle, player_dir)

	if difference != 0:
		if abs(difference) > 0.1:
			if real_rot < max_rotation_speed:
				real_rot = rotation_speed*SignalManager.dif_speed
			rotation += sign(dot) * deg2rad(real_rot) * delta
		else:
			shootMissile()
			
func shootMissile():
	var missiles = get_tree().get_nodes_in_group("missiles")
	if missiles.size() <= num_missiles + SignalManager.dif_speed and can_shoot:
		can_shoot = false
		
		var new_missile = load("res://Missile.tscn").instance()
		get_tree().get_root().get_node("Stage").add_child(new_missile)
		new_missile.start( global_transform )
		animationLauncher.play("Shooting")
		yield(animationLauncher, "animation_finished")
		can_shoot = true
	
	
