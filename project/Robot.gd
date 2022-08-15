class_name Robot
extends KinematicBody2D

const GRAVITY := 20

export var power_crystals := 1
export var health := 6

var _sword := System.new(false, 0)
var _shield := System.new(false, 0)
var _ranged := System.new(false, 0)
var _drones := System.new(false, 0)
var _horizontal_speed := 200
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


func hit(damage:int)->void:
	health -= damage
	if health <= 0:
		queue_free()
	print("ouch")
