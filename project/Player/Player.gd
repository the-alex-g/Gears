extends Robot

signal update_hud(parameter_name, new_value, new_max)

var _jump_speed := 475
var _scrap := 0

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
	emit_signal("update_hud", "health", _health, true)
	emit_signal("update_hud", "scrap", _scrap, false)
