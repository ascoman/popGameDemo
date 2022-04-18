extends RigidBody2D

var ball_color = ""
var is_active = false
var is_superball = false
var timer;

export var active_time = 4
export var impulse_strength = 300
export var SuperballChance = 15
export var superBallGravity = 250

onready var ballColShape = $BallCollision
onready var chargedParticles = $ChargedParticle
onready var onFireParticles = $Sprite/OnFireParticle
onready var SuperballParticles = $Sprite/SuperballParticle
onready var ballSprite = $Sprite
onready var gravityArea = $ContactArea
onready var ballAnimations = $AnimationPlayer

const superballSprite = preload("res://Sprites/16.png")
const defaultballSprite = preload("res://Sprites/01.png")
			
func _ready():
	add_to_group("balls")
	if ballSprite.texture == defaultballSprite:
		init_ball_color()
		
# warning-ignore:return_value_discarded
	SignalManager.connect("im_deleted_touching", self, "_on_ball_is_deleted")
	
func start(_transform, new_ball_color, _impulse):
	global_transform = _transform
	var angle = global_rotation - 1.5
	
	set_ball_color(new_ball_color)
	set_active_ball(true)
	apply_central_impulse(Vector2(cos(angle), sin(angle)) * (impulse_strength +(_impulse*10)))
	
func get_ball_color():
	return ball_color
	
func set_ball_color(color):
	ball_color = color
	ballSprite.texture = SignalManager.color_dict[ball_color]
	
	if color == SignalManager.SUPERBALL_COLOR:
		is_superball = true
		SuperballParticles.set_deferred("emitting", true)
		chargedParticles.set_deferred("emitting", false)
		gravityArea.gravity = superBallGravity

func init_ball_color():
	if SignalManager.posible_ball_colors.size() >= 1:
		randomize()
		var new_color = SignalManager.posible_ball_colors[randi() % SignalManager.posible_ball_colors.size()]
		set_ball_color(new_color)
		
func set_active_ball(set_active):
	var was_active = is_active
	
	is_active = set_active
	set_ball_on_fire(set_active)
	
	if is_superball == false:
		chargedParticles.set_deferred("emitting", set_active)
	
	if set_active == true:
		self.weight = self.weight*2
		timer = Timer.new()
		timer.set_one_shot(true)
		timer.set_timer_process_mode(Timer.TIMER_PROCESS_IDLE)
		timer.set_wait_time(active_time)
		timer.connect("timeout", self, "_on_ActiveTime_timeout")
		self.add_child(timer) 
		timer.start()
	else:
		if was_active == true:
			self.weight = self.weight/2
			if is_superball or find_3rd() == true:
				SignalManager._on_3rd_match(self)
			
func find_3rd():
	var overlappingnodes = gravityArea.get_overlapping_bodies()
	var ret = false
	var nodecount = 0

	
	for n_node in overlappingnodes:
		if self.name != n_node.name and self.get_ball_color() == n_node.get_ball_color():
			nodecount += 1
			if nodecount >= 2 or n_node.call_2nds(self.name) == true:
				ret = true
				break
	
	return ret
			
func call_2nds(abNodename):
	var overlappingnodes = gravityArea.get_overlapping_bodies()
	var ret = false
	
	for n_node in overlappingnodes:
		if self.name != n_node.name and self.get_ball_color() == n_node.get_ball_color() \
		and n_node.name != abNodename:
			ret = true
			break
			
	return ret

func set_ball_on_fire(on_fire):
	onFireParticles.set_deferred("emitting", on_fire)
	
	if on_fire:
		onFireParticles.show()

func _on_RigidBody2D_sleeping_state_changed():
	if is_active:
		set_active_ball(false)
		timer.queue_free()
		
func rocket_hit_ball():
	if is_superball == false:
		is_active = false
		set_ball_on_fire(false)
		explode()

func _on_ActiveTime_timeout():
	if is_active:
		set_active_ball(false)
	timer.queue_free()
		
func _on_ball_is_deleted(NodeNames, order, abNodeName):
	if NodeNames.has( self.name ) and is_instance_valid(self):
		delete_me(order+1, abNodeName)
	
func delete_me(order, abNodeName):
	var overlappingnodes = gravityArea.get_overlapping_bodies()
	var overlappingNodeNames = []
	
	if is_in_group("balls"):
		disconnect_signals()
		remove_from_group("balls")
		SignalManager.check_all_balls( self.name)
		
		onFireParticles.set_deferred("emitting",false)

		chargedParticles.set_deferred("emitting",true)
		
		if is_superball:
			for n_node in overlappingnodes:
				if self.name != n_node.name and n_node.is_in_group("balls"):
					overlappingNodeNames.push_back(n_node.name)
		else:
			for n_node in overlappingnodes:
				if self.name != n_node.name and self.get_ball_color() == n_node.get_ball_color() \
				and n_node.is_in_group("balls"):
					overlappingNodeNames.push_back(n_node.name)
		
		SignalManager.emit_signal("im_deleted_touching", overlappingNodeNames, order, abNodeName)
		
		yield(get_tree().create_timer( (order)/10.0), "timeout")

		for n_node2 in overlappingnodes:
			if is_instance_valid(n_node2):
				if self.name != n_node2.name and self.get_ball_color() != n_node2.get_ball_color():
					n_node2.set_deferred("sleeping",false)
					var dif = Vector2(self.global_position - n_node2.global_position)
					n_node2.apply_central_impulse(dif*-2)
					
		ballColShape.set_deferred("disabled",true)
		ballAnimations.play("explode")

		if order > 1:
			SignalManager.emit_signal("step_combo", abNodeName)
		
		yield(ballAnimations, "animation_finished")
		#print (self.name, "-", order, "-", ball_color, "-", overlappingNodeNames)
		queue_free()

func disconnect_signals():
	if SignalManager.is_connected ("im_deleted_touching", self, "_on_ball_is_deleted"):
		SignalManager.disconnect("im_deleted_touching", self, "_on_ball_is_deleted")

func explode():
	sleeping = true
	set_physics_process(false)
	remove_from_group("balls")
	SignalManager.check_all_balls( self.name)
	
	ballAnimations.play("explode")
	yield(ballAnimations, "animation_finished")
	queue_free()
	
func born():
	randomize()
	if 1 == (randi()%SuperballChance):
		set_ball_color(SignalManager.SUPERBALL_COLOR)
	else:
		SuperballParticles.set_deferred("emitting", false)
		init_ball_color()

	set_ball_on_fire(false)
	ballAnimations.play("Born")
