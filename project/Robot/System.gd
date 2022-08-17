class_name System
extends Node

var equipped := false
var upgrades = [] as PoolIntArray
var upgrade_paths : int

func _init(total_upgrade_paths := 1)->void:
	upgrade_paths = total_upgrade_paths
	for path in total_upgrade_paths:
		upgrades.append(0)


func upgrade(path := 0)->void:
	if upgrades[path] < 3:
		upgrades[path] += 1


func get_strength(path := 0)->int:
	return upgrades[path] + 1
