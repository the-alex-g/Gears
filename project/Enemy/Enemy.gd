extends Robot

enum PreferredWeapon {RANGED, SWORD, NONE}

const RANGED_DETECTION_DISTANCE := 416
const MELEE_DETECTION_DISTANCE := 128

var _upgrades := 0
var _speed := 100
var _target : KinematicBody2D
var _is_target_in_range := false
var _preferred_weapon : int
var _is_target_reachable := false

onready var _turn_detector = $"%TurnDetector" as RayCast2D
onready var _player_detection_area_collision = $PlayerDetectionArea/CollisionShape2D as CollisionShape2D
onready var _center_point = $"%CenterPoint" as Position2D


func _ready():
	generate()


func _physics_process(_delta:float)->void:
	# deploy drones
	if _drones.equipped and _drones_deployed < MAX_DRONES and _can_deploy_drone:
		_deploy_drone()
	
	# get left/right movement
	var horizontal = _direction * _speed
	
	# back off if you're ranged and have a target
	if _target != null and _preferred_weapon == PreferredWeapon.RANGED:
		horizontal *= -1
		# and do it slowly if your target is not nearby
		if not _is_target_in_range:
			horizontal /= 2
	
	# move
	var movement = Vector2(horizontal, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector2.UP)
	
	# AI function
	if _target != null:
		# move towards opponent if you like swords or bows
		if (_preferred_weapon == PreferredWeapon.SWORD and _is_target_reachable) or _preferred_weapon == PreferredWeapon.RANGED:
			# warning-ignore:narrowing_conversion
			_direction = sign(_target.global_position.x - global_position.x)
		# run away if you don't have a weapon
		elif _preferred_weapon == PreferredWeapon.NONE:
			# warning-ignore:narrowing_conversion
			_direction = sign(global_position.x - _target.global_position.x)
		
		# attack
		if _sword.equipped and _is_target_in_range and _can_attack_melee:
			_melee_attack()
		if _ranged.equipped and not _is_target_in_range and _can_attack_ranged:
			_ranged_attack()
	
		# update line-of-sight
		_update_target_reachable()
	
	# change direction if necessary
	if (is_on_wall() and (_target == null or not _is_target_reachable)) or not _turn_detector.is_colliding():
		_direction *= -1


func generate(level := 1)->void:
	_upgrades = level * 2
	
	# generate health
	_health = (randi() % _upgrades) + 1
	
	# equip one offensive system
	match randi() % 5:
		0, 1:
			_sword.equipped = true
		2, 3:
			_ranged.equipped = true
		4:
			_drones.equipped = true
	
	# equip/upgrade extra systems
	for upgrade in _upgrades - 1:
		match randi() % 10:
			0, 1:
				_sword = _upgrade_system(_sword)
			2, 3:
				_shield = _upgrade_system(_shield)
			4, 5:
				_ranged = _upgrade_system(_ranged)
			6:
				_drones = _upgrade_system(_drones)
			7:
				_health += 1
			8, 9:
				_speed += 50

	# randomize starting direction
	_direction = -1 if randi() % 2 == 0 else 1
	
	# set preferred weapon
	if _ranged.equipped and not _sword.equipped:
		_preferred_weapon = PreferredWeapon.RANGED
	elif _sword.equipped and not _ranged.equipped:
		_preferred_weapon = PreferredWeapon.SWORD
	elif _ranged.get_strength(WeaponPaths.DAMAGE) > _sword.get_strength(WeaponPaths.DAMAGE):
		_preferred_weapon = PreferredWeapon.RANGED
	elif _sword.get_strength(WeaponPaths.DAMAGE) >= _ranged.get_strength(WeaponPaths.DAMAGE):
		_preferred_weapon = PreferredWeapon.SWORD
	else:
		_preferred_weapon = PreferredWeapon.NONE
	
	if _ranged.equipped:
		_player_detection_area_collision.shape.extents.x = RANGED_DETECTION_DISTANCE


func _upgrade_system(system:System)->System:
	if system.equipped:
		system.upgrade(randi() % system.upgrade_paths)
	else:
		system.equipped = true
	return system


func _update_target_reachable()->void:
	var intersection := get_world_2d().direct_space_state.intersect_ray(_center_point.global_position, _target.get_global_position(), [self])
	if intersection.size() > 0:
		_is_target_reachable = intersection.collider == _target
	else:
		_is_target_reachable = false


func _on_PlayerDetectionArea_body_entered(body:PhysicsBody2D)->void:
	_target = body


func _on_PlayerDetectionArea_body_exited(_body:PhysicsBody2D)->void:
	_target = null
	_is_target_reachable = false


func _on_AttackArea_body_entered(body:PhysicsBody2D)->void:
	_is_target_in_range = true
	if body is Player:
		_start_melee_cooldown()


func _on_AttackArea_body_exited(_body:PhysicsBody2D)->void:
	_is_target_in_range = false
