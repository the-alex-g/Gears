extends Robot

var _jump_speed := 400


func _ready()->void:
	_sword.equipped = true


func _physics_process(_delta:float)->void:
	var horizontal := Input.get_axis("left", "right")
	# get vertical movement
	if is_on_floor():
		# jump
		if Input.is_action_just_pressed("jump"):
			_current_vertical_speed = -_jump_speed
		# stop vertical movement if on floor and not jumping
		elif _current_vertical_speed != 0:
			_current_vertical_speed = 0
	else:
		# fall
		if is_on_ceiling():
			_current_vertical_speed = 0
		if _current_vertical_speed < _max_fall_speed:
			_current_vertical_speed += GRAVITY
	
	# move
	var direction := Vector2(horizontal * _horizontal_speed, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(direction, Vector2.UP)



func _draw():
	draw_circle(Vector2.ONE * 16, 16, Color.red)
