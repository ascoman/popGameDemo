extends Node2D

# Declare member variables here. Examples:
var playing = true

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	SignalManager.connect("no_more_balls", self, "_on_no_more_balls", [], CONNECT_ONESHOT )
# warning-ignore:return_value_discarded
	SignalManager.connect("player_dead", self, "_on_player_dead", [], CONNECT_ONESHOT)
	
# warning-ignore:unused_argument
func _physics_process(delta):
	get_input()
	
func get_input():
	if Input.is_action_pressed("ui_cancel"):
		get_tree().paused = true
		var play_menu = load("res://PlayMenu.tscn").instance()
		add_child(play_menu)
		play_menu.global_position.y = (get_viewport_rect().size.y/4)*3.1
		play_menu.global_position.x = get_viewport_rect().size.x/2
		
func _on_no_more_balls():
	if playing == true:
		playing = false
		var new_message = load("res://MessagesPanel.tscn").instance()
		add_child(new_message)
		new_message.showMessage("WIN")
		var play_menu = load("res://PlayMenu.tscn").instance()
		add_child(play_menu)
		play_menu.global_position.y = (get_viewport_rect().size.y/4)*3.1
		play_menu.global_position.x = get_viewport_rect().size.x/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
func _on_player_dead():
	if playing == true:
		playing = false
		var new_message = load("res://MessagesPanel.tscn").instance()
		add_child(new_message)
		new_message.showMessage("LOSE")
		var play_menu = load("res://PlayMenu.tscn").instance()
		add_child(play_menu)
		play_menu.global_position.y = (get_viewport_rect().size.y/4)*3.1
		play_menu.global_position.x = get_viewport_rect().size.x/2

func _on_difTimer_timeout():
	if (SignalManager.dif_speed < 4.0):
		SignalManager.dif_speed += SignalManager.dif_step
