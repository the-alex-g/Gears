class_name Robot
extends KinematicBody2D

enum WeaponPaths {DAMAGE, COOLDOWN}
enum DronePaths {DAMAGE, SPEED, HEALTH}

const GRAVITY := 20

var _power_crystals := 1
var _health := 6
var _sword := System.new(2)
var _shield := System.new()
var _ranged := System.new(2)
var _drones := System.new(3)
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


func hit(damage_dealt:int)->void:
	if _shield.equipped:
		damage_dealt = max(damage_dealt / _shield.get_strength(), 1)
	_health -= damage_dealt
	if _health <= 0:
		_health = 0
		queue_free()
	print("ouch")
