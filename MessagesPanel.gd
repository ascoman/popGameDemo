extends Node2D

onready var animationMessage = $AnimationPlayer
onready var labeltext = $PanelContainer/Label

var showing = false

func _ready():
	pass # Replace with function body.
	
func _init():
	pass

func showMessage(message):
	if showing == false :
		global_position.y = get_viewport_rect().size.y/2
		global_position.x = get_viewport_rect().size.x/2
		showing = true
		labeltext.text = message
		animationMessage.play("show text")
		yield(animationMessage, "animation_finished")
		get_tree().paused = true
