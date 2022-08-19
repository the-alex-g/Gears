extends CanvasLayer

signal update_scrap(new_value)
signal upgrade_system(system_name, path, cost)

onready var _health_bar = $"%Health" as ProgressBar
onready var _scrap_label = $"%Scrap" as Label
onready var _upgrade_container = $Control/UpgradeContainer as VBoxContainer

var _scrap := 0 setget _set_scrap


func _on_Main_player_update_hud(parameter_name:String, new_value, new_max:bool)->void:
	match parameter_name:
		"health":
			if new_max:
				_health_bar.max_value = new_value
			_health_bar.value = new_value
		"scrap":
			_set_scrap(new_value)


func _on_UpgradeContainer_upgrade_system(system_name:String, scrap_reduction:int, path:int)->void:
	_set_scrap(_scrap - scrap_reduction)
	emit_signal("upgrade_system", system_name, path, scrap_reduction)


func _set_scrap(value)->void:
	_scrap = value
	_scrap_label.text = str(_scrap)
	emit_signal("update_scrap", _scrap)
