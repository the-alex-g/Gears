extends Robot

signal update_hud(parameter_name, new_value, new_max)

const STARTING_HEALTH := 6

var _jump_speed := 475
var _scrap := 40

onready var _melee_hit_area = $"%AttackArea" as Area2D


func _ready()->void:
	_sword.equipped = true


func _physics_process(_delta:float)->void:
	# get left/right movement
	var horizontal := Input.get_axis("left", "right") * _horizontal_speed
	
	# jump
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			_current_vertical_speed = -_jump_speed
	
	# move
	var direction := Vector2(horizontal, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(direction, Vector2.UP)
	
	# attack
	if Input.is_action_just_pressed("melee") and _sword.equipped:
		_melee_attack()
	if Input.is_action_just_pressed("ranged") and _ranged.equipped:
		_ranged_attack()


func _melee_attack()->void:
	for body in _melee_hit_area.get_overlapping_bodies():
		if body is Robot:
			body.hit(_sword.strength)


func _ranged_attack()->void:
	pass


# custom hit function is needed to update the HUD after taking damage
func hit(damage_dealt:int)->void:
	.hit(damage_dealt)
	emit_signal("update_hud", "health", _health, false)


func _draw():
	draw_circle(Vector2.ONE * 16, 16, Color.red)


# do starting configuration of HUD here
func _on_Main_ready()->void:
	emit_signal("update_hud", "health", STARTING_HEALTH, true)
	emit_signal("update_hud", "scrap", _scrap, false)


func _on_Main_upgrade_system(system_name:String)->void:
	match system_name:
		"armor":
			_health += 1
			emit_signal("update_hud", "health", _health, true if _health > STARTING_HEALTH else false)
		"drone":
			if _drones.equipped:
				_drones.upgrade()
			else:
				_drones.equipped = true
		"movement":
			_horizontal_speed += 50
		"ranged":
			if _ranged.equipped:
				_ranged.upgrade()
			else:
				_ranged.equipped = true
		"shield":
			if _shield.equipped:
				_shield.upgrade()
			else:
				_shield.equipped = true
		"sword":
			_sword.upgrade()
