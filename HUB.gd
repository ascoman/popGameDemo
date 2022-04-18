extends Node2D
var totalscore = 0

onready var score_label = $ScoreContainer/ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	SignalManager.connect("add_score", self, "addScore", [], CONNECT_DEFERRED)
	addScore(0)

func addScore(score):
	totalscore += score
	score_label.text = "SCORE : " + str(totalscore)
