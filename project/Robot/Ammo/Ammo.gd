extends FallingObject

const SPEED_DECREASE_PER_SECOND := 100.0
const ANIM_LENGTH := 8

var direction := Vector2(1, 0).rotated( - TAU / 14)
var _speed := 800.0
var good : bool setget _set_good
var damage := 0
var index : int setget _set_index


func _ready()->void:
	$AnimatedSprite.frame = randi() % ANIM_LENGTH


func _physics_process(delta:float)->void:
	var movement := direction * _speed
	movement.y += _current_vertical_speed
	movement *= delta
	var collision := move_and_collide(movement)
	if collision:
		if collision.collider.has_method("hit"):
			collision.collider.hit(damage)
		_queue_free()
	_speed -= delta * SPEED_DECREASE_PER_SECOND
	if _speed <= 0:
		_queue_free()


func _queue_free()->void:
	# custom queue_free method to create explosion
	var explosion = preload("res://Explosion/Explosion.tscn").instance() as AnimatedSprite
	explosion.position = global_position
	get_parent().add_child(explosion)
	queue_free()



func _set_good(value:bool)->void:
	if value:
		set_collision_mask_bit(1, false)
	else:
		set_collision_mask_bit(2, false)


func _set_index(value:int)->void:
	_speed -= (value - 1) * 100
