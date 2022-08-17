extends FallingObject

const SPEED_DECREASE_PER_SECOND := 100.0

var direction := Vector2(1, 0).rotated( - TAU / 12)
var _speed := 800.0
var good : bool setget _set_good
var damage := 0


func _physics_process(delta:float)->void:
	var movement := direction * _speed
	movement.y += _current_vertical_speed
	movement *= delta
	var collision := move_and_collide(movement)
	if collision:
		if collision.collider is Robot:
			collision.collider.hit(damage)
		queue_free()
	_speed -= delta * SPEED_DECREASE_PER_SECOND
	if _speed <= 0:
		queue_free()


func _draw()->void:
	draw_circle(Vector2.ZERO, 4, Color.green)


func _set_good(value:bool)->void:
	if value:
		set_collision_mask_bit(1, false)
	else:
		set_collision_mask_bit(2, false)
