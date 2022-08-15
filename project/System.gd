class_name System
extends Node

var equipped := false
var upgrades := 1

func _init(starting_equip:bool, starting_upgrades:int)->void:
	equipped = starting_equip
	upgrades = starting_upgrades


func upgrade()->void:
	if upgrades < 3:
		upgrades += 1


func strength()->int:
	return upgrades + 1
