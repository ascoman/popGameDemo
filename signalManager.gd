extends Node

const BALL_COLOR_1 = "blue"
const BALL_COLOR_2 = "green"
const BALL_COLOR_3 = "purple"
const BALL_COLOR_4 = "red"
const BALL_COLOR_5 = "yellow"
const SUPERBALL_COLOR = "SuperballColor"

var color_dict = {BALL_COLOR_1: preload("res://Sprites/06.png"), 
					BALL_COLOR_2: preload("res://Sprites/08.png"), 
					BALL_COLOR_3: preload("res://Sprites/15.png"),
					BALL_COLOR_4:preload("res://Sprites/13.png"), 
					BALL_COLOR_5:preload("res://Sprites/04.png"), 
					SUPERBALL_COLOR:preload("res://Sprites/16.png")}

var ball_colors = [BALL_COLOR_1, BALL_COLOR_2, BALL_COLOR_3, BALL_COLOR_4, BALL_COLOR_5]
var posible_ball_colors = ball_colors
var dif_speed = 1.0
var dif_step = 0.15

#signal destroyed_ball(NodeName)
# warning-ignore:unused_signal
signal im_deleted_touching(NodesTouching, order, abNode)
# warning-ignore:unused_signal
signal step_combo(abNode)
# warning-ignore:unused_signal
signal add_score(score)

signal no_more_balls
# warning-ignore:unused_signal
signal player_dead

func _on_3rd_match(ab_Node):
	var new_combo = load("res://ComboMessage.tscn").instance()
	get_tree().get_root().get_node("Stage").add_child(new_combo)

	new_combo.call_deferred("BeginCombo", ab_Node)
	
	ab_Node.delete_me(1, ab_Node.name)
	
func _set_posible_colors(NodeName):
	var all_balls = get_tree().get_nodes_in_group("balls")
	var new_ball_colors = []
	
	for ball in all_balls:
		if new_ball_colors.has(ball.get_ball_color()) == false and NodeName != ball.name and ball.get_ball_color() != SUPERBALL_COLOR:
			new_ball_colors.push_back(ball.get_ball_color())
	
	if new_ball_colors.size() > 0:
		posible_ball_colors = new_ball_colors
	else:
		posible_ball_colors = ball_colors

# warning-ignore:unused_argument
func check_all_balls(my_NodeName):
	_set_posible_colors(my_NodeName)
	var all_balls = get_tree().get_nodes_in_group("balls")
	
	if all_balls.size() < 1:
		emit_signal("no_more_balls")
		
func init_globals():
	posible_ball_colors = ball_colors
	dif_speed = 1.0
	
