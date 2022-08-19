extends FallingObject

var _force := 200.0

onready var _horizontal := randf() - 0.5


func _ready()->void:
	# warning-ignore:narrowing_conversion
	_current_vertical_speed = -_force
	$AnimatedSprite.play("default", randi() % 2 == 0)


func _physics_process(delta:float)->void:
	var movement := Vector2(_horizontal * _force, _current_vertical_speed)
	if _force > 0.0:
		_force -= 100.0 * delta
	else:
		_force = 0.0
	if _current_vertical_speed != 0:
		# warning-ignore:return_value_discarded
		move_and_slide(movement, Vector2.UP)


func _on_PickupArea_body_entered(body:PhysicsBody2D)->void:
	if body is Player:
		body.pickup("scrap")
		queue_free()
