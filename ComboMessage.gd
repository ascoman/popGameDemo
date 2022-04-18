extends Node2D

var counter = 1
var abnodeName = ""
var ballValue = 10

onready var animator = $AnimationPlayer
onready var labeltext = $PanelContainer/Label
onready var timer = $Timer

func _ready():
	# warning-ignore:return_value_discarded
	SignalManager.connect("step_combo", self, "stepit", [], CONNECT_DEFERRED)

func BeginCombo(NewAbnode):
	 
	var centerball = get_tree().get_root().find_node("CenterBall", true, false)
	var centerballpos = centerball.global_position
	var nodepos = NewAbnode.global_position
	abnodeName = NewAbnode.name
	
	if (nodepos.x - centerballpos.x) >= 0:
		self.global_position.x = nodepos.x + 80
	else:
		self.global_position.x = nodepos.x - 80
		
	if (nodepos.y - centerballpos.y) >= 0:
		self.global_position.y = nodepos.y + 80
	else:
		self.global_position.y = nodepos.y - 80
		
	labeltext.text = "x"+str(counter)
	SignalManager.emit_signal("add_score", ballValue)
	animator.play("start")
	yield(animator, "animation_finished")

func stepit(signalAbNodeName):
	if ( signalAbNodeName == abnodeName ):
		timer.start()
		counter += 1
		SignalManager.emit_signal("add_score", ballValue*counter)
		labeltext.text = "x"+str(counter)
		animator.play("bounce")
		yield(animator, "animation_finished")
		
func endCombo():
	animator.play("finish")
	yield(animator, "animation_finished")
	queue_free()

func _on_Timer_timeout():
	endCombo()
