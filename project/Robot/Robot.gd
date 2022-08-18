class_name Robot
extends FallingObject

enum WeaponPaths {DAMAGE, COOLDOWN}
enum DronePaths {DAMAGE, SPEED, HEALTH}

const RANGED_COOLDOWN_TIME := 1.0
const MELEE_COOLDOWN_TIME := 1.0
const COOLDOWN_STEP := 0.2

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

onready var _firing_point = $"%FiringPoint" as Position2D
onready var _melee_cooldown_timer = $"%MeleeCooldownTimer" as Timer
onready var _ranged_cooldown_timer = $"%RangedCooldownTimer" as Timer
onready var _melee_hit_area = $"%AttackArea" as Area2D
onready var _sprite = $"%Sprite" as Sprite


func _process(_delta:float)->void:
	# flip sprite to match movement direction
	if _direction < 0:
		_sprite.scale.x = -1
	else:
		_sprite.scale.x = 1


func _melee_attack()->void:
	for body in _melee_hit_area.get_overlapping_bodies():
		if body.has_method("hit"):
			body.hit(_sword.get_strength(WeaponPaths.DAMAGE))
	_start_melee_cooldown()


func _ranged_attack()->void:
	var ammo = preload("res://Robot/Ammo.tscn").instance() as KinematicBody2D
	ammo.direction.x *= _direction
	ammo.position = _firing_point.global_position
	ammo.good = is_player
	ammo.damage = _ranged.get_strength(WeaponPaths.DAMAGE)
	get_parent().add_child(ammo)
	_start_ranged_cooldown()


func _start_melee_cooldown()->void:
	_can_attack_melee = false
	_melee_cooldown_timer.start(MELEE_COOLDOWN_TIME - _sword.get_strength(WeaponPaths.COOLDOWN) * COOLDOWN_STEP)
	yield(_melee_cooldown_timer, "timeout")
	_can_attack_melee = true


func _start_ranged_cooldown()->void:
	_can_attack_ranged = false
	_ranged_cooldown_timer.start(RANGED_COOLDOWN_TIME - _ranged.get_strength(WeaponPaths.COOLDOWN) * COOLDOWN_STEP)
	yield(_ranged_cooldown_timer, "timeout")
	_can_attack_ranged = true


func hit(damage_dealt:int)->void:
	if _shield.equipped:
		damage_dealt = max(damage_dealt / _shield.get_strength(), 1)
	_health -= damage_dealt
	if _health <= 0:
		_health = 0
		queue_free()
	print("ouch ", _health)
