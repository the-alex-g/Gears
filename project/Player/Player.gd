extends Robot

signal update_hud(parameter_name, new_value, new_max)

const STARTING_HEALTH := 6

var _jump_speed := 475
var _scrap := 40


func _ready()->void:
	_sword.equipped = true
	_ranged.equipped = true


func _physics_process(_delta:float)->void:
	# get left/right movement
	var horizontal := Input.get_axis("left", "right") * _horizontal_speed
	if horizontal != 0:
		# warning-ignore:narrowing_conversion
		_direction = sign(horizontal)
	
	# jump
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			_current_vertical_speed = -_jump_speed
	
	# move
	var direction := Vector2(horizontal, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(direction, Vector2.UP)
	
	# attack
	if Input.is_action_just_pressed("melee") and _sword.equipped and _can_attack_melee:
		_melee_attack()
	if Input.is_action_just_pressed("ranged") and _ranged.equipped and _can_attack_ranged:
		_ranged_attack()


# custom hit function is needed to update the HUD after taking damage
func hit(damage_dealt:int)->void:
	.hit(damage_dealt)
	emit_signal("update_hud", "health", _health, false)


func _draw():
	draw_circle(Vector2.ONE * 16, 16, Color.red)


# do starting configuration of HUD here,
# because the player is not ready at the
# same time the HUD is.
func _on_Main_ready()->void:
	emit_signal("update_hud", "health", STARTING_HEALTH, true)
	emit_signal("update_hud", "scrap", _scrap, false)


func _on_Main_upgrade_system(system_name:String, path:int)->void:
	match system_name:
		"armor":
			_health += 1
			emit_signal("update_hud", "health", _health, true if _health > STARTING_HEALTH else false)
		"drone":
			if _drones.equipped:
				_drones.upgrade(path)
			else:
				_drones.equipped = true
		"movement":
			_horizontal_speed += 50
		"ranged":
			if _ranged.equipped:
				_ranged.upgrade(path)
			else:
				_ranged.equipped = true
		"shield":
			if _shield.equipped:
				_shield.upgrade()
			else:
				_shield.equipped = true
		"sword":
			_sword.upgrade(path)
