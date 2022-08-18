class_name Drone
extends FallingObject

signal destroyed

const COOLDOWN_TIME := 1
const MAX_DISTANCE_FROM_OWNER := 50
const TERMINATION_DISTANCE := 400

var good : bool setget _set_good
var drone_owner : KinematicBody2D
var damage : int
var health : int
var speed := 200
var direction := 1
var _is_target_in_range := false
var _is_target_reachable := false
var _target : KinematicBody2D setget _set_target
var _can_attack := true

onready var _attack_area = $"%AttackArea" as Area2D
onready var _detection_area = $"%DetectionArea" as Area2D
onready var _sprite = $"%Sprite" as Sprite
onready var _turn_detector = $"%TurnDetector" as RayCast2D
onready var _cooldown_timer = $CooldownTimer as Timer


func _physics_process(_delta:float)->void:
	if not drone_owner:
		return
	# move
	var horizontal := speed * direction
	var movement := Vector2(horizontal, _current_vertical_speed)
	# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector2.UP)
	
	if _target and _is_target_reachable:
		# go towards target and attack
		# warning-ignore:narrowing_conversion
		direction = sign(_target.global_position.x - global_position.x)
		
		if _is_target_in_range and _can_attack:
			_attack()
	
	else: # no reachable target
		# stay near owner
		var distance_from_owner := abs(global_position.x - drone_owner.global_position.x)
		if distance_from_owner > MAX_DISTANCE_FROM_OWNER:
			if sign(global_position.x - drone_owner.global_position.x) < 0:
				direction = 1
			else:
				direction = -1

		# if can't get to owner, explode
		if distance_from_owner > TERMINATION_DISTANCE:
			hit(health)
	
	# change direction if necessary
	if is_on_wall() and (_target == null or not _is_target_reachable):
		direction *= -1
	if not _turn_detector.is_colliding():
		direction *= -1
	
	# make sprite face proper direction
	_sprite.scale.x = direction
	
	if _target != null:
		_update_target_reachable()


func _attack()->void:
	for body in _attack_area.get_overlapping_bodies():
		if body.has_method("hit"):
			body.hit(damage)
	_start_attack_cooldown()


func _start_attack_cooldown()->void:
	_can_attack = false
	_cooldown_timer.start(COOLDOWN_TIME)
	yield(_cooldown_timer, "timeout")
	_can_attack = true


func _update_target_reachable()->void:
	if _target == null:
		return
	var intersection := get_world_2d().direct_space_state.intersect_ray(_sprite.global_position, _target.get_global_position(), [self])
	if intersection.size() > 0:
		_is_target_reachable = intersection.collider == _target
	else:
		_is_target_reachable = false


func hit(damage_dealt:int, send_signal:bool = true)->void:
	health -= damage_dealt
	if health <= 0:
		if send_signal:
			emit_signal("destroyed")
		queue_free()


func _on_AttackArea_body_entered(_body:PhysicsBody2D)->void:
	_is_target_in_range = true


func _on_AttackArea_body_exited(_body:PhysicsBody2D)->void:
	_is_target_in_range = false


func _on_DetectionArea_body_entered(body:PhysicsBody2D)->void:
	if _target == null:
		_set_target(body)


func _on_DetectionArea_body_exited(_body:PhysicsBody2D)->void:
	_set_target(null)


func _on_owner_destroyed()->void:
	hit(health, false)


func _on_target_destroyed()->void:
	_set_target(null)


func _set_good(value:bool)->void:
	good = value
	# set collision masks to detect appropriate targets
	if good:
		_attack_area.set_collision_mask_bit(2, true)
		_detection_area.set_collision_mask_bit(2, true)
		set_collision_layer_bit(1, true)
	else:
		_attack_area.set_collision_mask_bit(1, true)
		_detection_area.set_collision_mask_bit(1, true)
		set_collision_layer_bit(2, true)


func _set_target(value:KinematicBody2D)->void:
	if value == null:
		_is_target_reachable = false
#		if good:
#			var detectable_bodies = _detection_area.get_overlapping_bodies() as Array
#			if detectable_bodies.size() > 0:
#				_target = detectable_bodies[randi() % detectable_bodies.size()]
	else:
		# warning-ignore:return_value_discarded
		if not value.is_connected("destroyed", self, "_on_target_destroyed"):
			value.connect("destroyed", self, "_on_target_destroyed", [], CONNECT_ONESHOT)
	_target = value


func _draw()->void:
	draw_circle(_sprite.position, 8, Color.yellow)
