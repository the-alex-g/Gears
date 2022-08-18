class_name Robot
extends FallingObject

signal destroyed

enum WeaponPaths {DAMAGE, COOLDOWN}
enum DronePaths {DAMAGE, SPEED, HEALTH}

const RANGED_COOLDOWN_TIME := 1.0
const MELEE_COOLDOWN_TIME := 1.0
const DRONE_COOLDOWN_TIME := 1.0
const COOLDOWN_STEP := 0.2
const MAX_DRONES := 4

export var is_player := false

var _power_crystals := 1
var _health := 6
var _sword := System.new(2)
var _shield := System.new()
var _ranged := System.new(2)
var _drones := System.new(3)
var _horizontal_speed := 200
var _direction := 1
var _can_attack_melee := true
var _can_attack_ranged := true
var _drones_deployed := 0
var _can_deploy_drone := true

onready var _firing_point = $"%FiringPoint" as Position2D
onready var _melee_cooldown_timer = $MeleeCooldownTimer as Timer
onready var _ranged_cooldown_timer = $RangedCooldownTimer as Timer
onready var _drone_deploy_timer = $DroneDeployTimer as Timer
onready var _melee_hit_area = $"%AttackArea" as Area2D
onready var _sprite = $"%Sprite" as Sprite


func _process(_delta:float)->void:
	# flip sprite to match movement direction
	if _direction < 0:
		_sprite.scale.x = -1
	else:
		_sprite.scale.x = 1


func _deploy_drone()->void:
	var drone = preload("res://Robot/Drone/Drone.tscn").instance() as Drone
	_drones_deployed += 1
	get_parent().add_child(drone)
	_can_deploy_drone = false
	# wait until drone is ready to set all its values
	drone.drone_owner = self
	drone.damage = _drones.get_strength(DronePaths.DAMAGE)
	drone.health = _drones.get_strength(DronePaths.HEALTH)
	drone.speed += _drones.get_strength(DronePaths.SPEED)
	drone.position = global_position
	#yield(drone, "ready")
	drone.good = is_player
	drone.connect("destroyed", self, "_on_drone_destroyed", [], CONNECT_ONESHOT)
	# warning-ignore:return_value_discarded
	connect("destroyed", drone, "_on_owner_destroyed", [], CONNECT_ONESHOT)
	# start cooldown timer
	_drone_deploy_timer.start(DRONE_COOLDOWN_TIME)
	yield(_drone_deploy_timer, "timeout")
	_can_deploy_drone = true


func _on_drone_destroyed()->void:
	_drones_deployed -= 1


func _melee_attack()->void:
	for body in _melee_hit_area.get_overlapping_bodies():
		if body.has_method("hit"):
			body.hit(_sword.get_strength(WeaponPaths.DAMAGE))
	_start_melee_cooldown()


func _ranged_attack()->void:
	_can_attack_ranged = false
	var Ammo := preload("res://Robot/Ammo/Ammo.tscn")
	for i in _ranged.get_strength(WeaponPaths.DAMAGE):
		var ammo = Ammo.instance() as KinematicBody2D
		ammo.direction.x *= _direction
		ammo.position = _firing_point.global_position
		ammo.good = is_player
		ammo.damage = _ranged.get_strength(WeaponPaths.DAMAGE)
		ammo.index = i
		get_parent().add_child(ammo)
		yield(get_tree().create_timer(0.1), "timeout")
	_ranged_cooldown_timer.start(RANGED_COOLDOWN_TIME - _ranged.get_strength(WeaponPaths.COOLDOWN) * COOLDOWN_STEP)
	yield(_ranged_cooldown_timer, "timeout")
	_can_attack_ranged = true


func _start_melee_cooldown()->void:
	_can_attack_melee = false
	_melee_cooldown_timer.start(MELEE_COOLDOWN_TIME - _sword.get_strength(WeaponPaths.COOLDOWN) * COOLDOWN_STEP)
	yield(_melee_cooldown_timer, "timeout")
	_can_attack_melee = true


func hit(damage_dealt:int)->void:
	if _shield.equipped:
# warning-ignore:integer_division
		damage_dealt = max(damage_dealt / _shield.get_strength(), 1)
	_health -= damage_dealt
	if _health <= 0:
		_health = 0
		emit_signal("destroyed")
		queue_free()
	print("ouch ", _health)


func get_global_position()->Vector2:
	return global_position + _sprite.position
