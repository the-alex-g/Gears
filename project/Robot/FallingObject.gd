class_name FallingObject
extends KinematicBody2D

const GRAVITY := 20

var _max_fall_speed := 600
var _current_vertical_speed := 0


func _physics_process(_delta:float)->void:
	# handle falling
	if is_on_floor():
		# reset gravity if on floor
		if _current_vertical_speed != 0:
			_current_vertical_speed = 0
	else: # apply gravity
		if is_on_ceiling() and _current_vertical_speed < 0: # if you hit a ceiling, stop going up
			_current_vertical_speed = 0
		if _current_vertical_speed < _max_fall_speed:
			_current_vertical_speed += GRAVITY
