extends Node2D

signal player_update_hud(parameter_name, new_value, new_max)
signal upgrade_system(system_name)

onready var _hud := $HUD


func _on_Player_update_hud(parameter_name:String, new_value, new_max:bool):
	emit_signal("player_update_hud", parameter_name, new_value, new_max)


func _on_HUD_upgrade_system(system_name:String)->void:
	emit_signal("upgrade_system", system_name)
