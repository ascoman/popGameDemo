extends Node2D

onready var btnStart = $PanelContainer/HBoxContainer/ButtonStart

var is_main = false

func _ready():
	if get_tree().paused == true:
		btnStart.text = ' Continue '

func _on_ButtonStart_pressed():
	if is_main == true:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Stage.tscn")
	else:
		if btnStart.text == ' Continue ':
			get_tree().paused = false
			queue_free()
		else:
			get_parent().playing = true
			get_tree().paused = false
			SignalManager.init_globals()
	# warning-ignore:return_value_discarded
			get_parent().get_tree().reload_current_scene()
		
func _on_ButtonExit_pressed():
	get_tree().quit()
