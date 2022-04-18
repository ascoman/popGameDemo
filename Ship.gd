extends StaticBody2D

# Called when the node enters the scene tree for the first time.
var can_shoot = true
var can_move = true
var impulse_strength = 800
var shoot_charge_step = 3
onready var nextBall = $NextBall
onready var shootBar = $ShootBar
onready var ballPosition = $BallPosition
onready var shootTimer = $shootTimer

func _ready():
	nextBall.remove_from_group("balls")
	nextBall.born()
	yield(get_tree().create_timer(1.0), "timeout")
	_on_can_shoot()
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if can_shoot:
		if Input.is_action_pressed("shoot") :
			shootBar.value += shoot_charge_step
			
		if Input.is_action_just_released("shoot") :
			shoot()
			shootBar.value = 0
		
		if Input.is_action_just_pressed("shoot") and can_shoot == true:
			shootBar.value = 0
		
func shoot():
	can_shoot = false
	var shooting_ball = load("res://Ball.tscn").instance()
	
	get_tree().get_root().get_node("Stage").add_child(shooting_ball)
	shooting_ball.start(ballPosition.global_transform, nextBall.get_ball_color(), shootBar.value)
	
	SignalManager._set_posible_colors(shooting_ball.name)
	nextBall.born()
	
	shootTimer.start()
	
func _on_can_shoot():
	nextBall.set_ball_on_fire(true)
	can_shoot = true

func on_kill_shp():
	SignalManager.emit_signal("player_dead")
	can_shoot = false
	can_move = false

func _on_shootTimer_timeout():
	_on_can_shoot()
