extends Area2D

export var speed = 60.0
export var maxspeed = 100.0
export var steer_force = 10.0

onready var ship = get_tree().get_root().find_node("Ship", true, false)
onready var smokeParticles = $Particles2D
onready var missileAnimator = $AnimationPlayer

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

func _ready():
	add_to_group("missiles")
	
func start(_transform):
	global_transform = _transform
	rotation += rand_range(-0.01, 0.01)
	velocity = transform.x 
	
func seek():
	var steer = Vector2.ZERO
	if ship:
		var desired = (ship.global_position - global_position).normalized() * (speed*(SignalManager.dif_speed*2))      
		steer = (desired - velocity).normalized() * (steer_force*SignalManager.dif_speed)
	return steer
	
func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.clamped(maxspeed)
	rotation = velocity.angle()
	position += velocity * delta
	
func _on_Missile_body_entered(body):
	
	if body.name == "Ship":
		body.on_kill_shp()
		explode()
	elif body.is_in_group("balls") and body.is_superball == false:
		if body.is_active == true:
			body.rocket_hit_ball()
	else:
		explode()
			
func _on_Lifetime_timeout():
	if is_instance_valid(self):
		explode()

func explode():
	if is_in_group("missiles"):
		remove_from_group("missiles")
		smokeParticles.emitting = false
		set_physics_process(false)
		velocity = Vector2.ZERO
		missileAnimator.play("explode")
		yield(missileAnimator, "animation_finished")
		queue_free()
	
