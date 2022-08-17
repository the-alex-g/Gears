class_name Robot
extends FallingObject

enum WeaponPaths {DAMAGE, COOLDOWN}
enum DronePaths {DAMAGE, SPEED, HEALTH}

var _power_crystals := 1
var _health := 6
var _sword := System.new(2)
var _shield := System.new()
var _ranged := System.new(2)
var _drones := System.new(3)
var _horizontal_speed := 200


func hit(damage_dealt:int)->void:
	if _shield.equipped:
		damage_dealt = max(damage_dealt / _shield.get_strength(), 1)
	_health -= damage_dealt
	if _health <= 0:
		_health = 0
		queue_free()
	print("ouch")
