extends AnimatedSprite

const POSSIBLE_ROTATIONS := [0, TAU / 4, PI, 3 * TAU / 4]


func _ready()->void:
	rotation = POSSIBLE_ROTATIONS[randi() % 4]
	play("Boom")
	frame = 0


func _on_Explosion_animation_finished()->void:
	queue_free()
