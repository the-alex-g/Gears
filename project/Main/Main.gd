extends Node2D

signal player_update_hud(parameter_name, new_value, new_max)

onready var _hud := $HUD


func _on_Player_update_hud(parameter_name:String, new_value, new_max:bool):
	emit_signal("player_update_hud", parameter_name, new_value, new_max)
