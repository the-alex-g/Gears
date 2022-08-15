extends Robot

var _jump_speed := 475


func _ready()->void:
	_sword.equipped = true


func _physics_process(_delta:float)->void:
	# get sideways movement
	var horizontal := Input.get_axis("left", "right") * _horizontal_speed
	
	# jump
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			_current_vertical_speed = -_jump_speed
	
	# move
	var direction := Vector2(horizontal, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(direction, Vector2.UP)


func _draw():
	draw_circle(Vector2.ONE * 16, 16, Color.red)
