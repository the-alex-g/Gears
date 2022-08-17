extends Robot

enum PreferredWeapon {RANGED, SWORD, NONE}

var _upgrades := 0
var _speed := 100
var _target : KinematicBody2D
var _is_target_in_range := false
var _preferred_weapon : int

onready var _turn_detector = $"%TurnDetector" as RayCast2D


func _ready():
	generate()


func _physics_process(_delta:float)->void:
	# get left/right movement
	var horizontal = _direction * _speed
	
	# back off slowly if you're ranged and have a target and your target is not nearby
	if _target != null and _preferred_weapon == PreferredWeapon.RANGED and not _is_target_in_range:
		horizontal /= 2
	
	# move
	var movement = Vector2(horizontal, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector2.UP)
	
	# change direction if necessary
	if (is_on_wall() and _target == null) or not _turn_detector.is_colliding():
		_direction *= -1
	
	# AI function
	if _target != null:
		# move towards opponent if you like swords
		if _preferred_weapon == PreferredWeapon.SWORD:
			_direction = sign(_target.global_position.x - global_position.x)
		# run away if you don't have a weapon, or if you like ranged
		elif _preferred_weapon == PreferredWeapon.NONE or _preferred_weapon == PreferredWeapon.RANGED:
			_direction = sign(global_position.x - _target.global_position.x)
		
		# attack
		if _sword.equipped and _is_target_in_range and _can_attack_melee:
			_melee_attack()
		if _ranged.equipped and not _is_target_in_range and _can_attack_ranged:
			_ranged_attack()


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
	else:
		_preferred_weapon = PreferredWeapon.NONE


func _upgrade_system(system:System)->System:
	if system.equipped:
		system.upgrade(randi() % system.upgrade_paths)
	else:
		system.equipped = true
	return system


func _draw()->void:
	draw_circle(Vector2.ONE * 16, 16, Color.greenyellow)


func _on_PlayerDetectionArea_body_entered(body:PhysicsBody2D)->void:
	_target = body


func _on_PlayerDetectionArea_body_exited(_body:PhysicsBody2D)->void:
	_target = null
	# turn around if you like ranged!
	if _preferred_weapon == PreferredWeapon.RANGED:
		_direction *= -1


func _on_AttackArea_body_entered(_body:PhysicsBody2D)->void:
	_is_target_in_range = true


func _on_AttackArea_body_exited(_body:PhysicsBody2D)->void:
	_is_target_in_range = false
