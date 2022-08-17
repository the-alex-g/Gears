extends Robot

var _upgrades := 0
var _move_direction := -1
var _speed := 100

onready var _turn_detector = $"%TurnDetector" as RayCast2D
onready var _sprite = $Sprite as Sprite


func _physics_process(_delta:float)->void:
	# get left/right movement
	var horizontal = _move_direction * _speed
	
	# move
	var direction = Vector2(horizontal, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(direction, Vector2.UP)
	
	# change direction if necessary
	if is_on_wall() or not _turn_detector.is_colliding():
		_move_direction *= -1
	
	# flip sprite to match movement direction
	if _move_direction < 0:
		_sprite.scale.x = -1
	else:
		_sprite.scale.x = 1


func generate(level := 1)->void:
	_upgrades = level * 2
	
	# generate health
	_health = (randi() % _upgrades) + 1
	
	# equip one offensive system
	match randi() % 3:
		0:
			_sword.equipped = true
		1:
			_ranged.equipped = true
		2:
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
	match randi() % 2:
		0:
			_move_direction = -1
		1:
			_move_direction = 1


func _upgrade_system(system:System)->System:
	if system.equipped:
		system.upgrade(randi() % system.upgrade_paths)
	else:
		system.equipped = true
	return system


func _draw()->void:
	draw_circle(Vector2.ONE * 16, 16, Color.greenyellow)
