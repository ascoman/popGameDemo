extends KinematicBody2D

export (float) var ROTATION_SPEED = 4

func rotate_gear(rotation_Direction, _delta): 
	rotation += rotation_Direction * ROTATION_SPEED * _delta
