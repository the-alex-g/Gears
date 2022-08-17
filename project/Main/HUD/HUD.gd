extends CanvasLayer

signal update_scrap(new_value)
signal upgrade_system(system_name)

onready var _health_bar = $"%Health" as ProgressBar
onready var _scrap_label = $"%Scrap" as Label
onready var _upgrade_container = $Control/UpgradeContainer as VBoxContainer

var _scrap := 0


func _on_Main_player_update_hud(parameter_name:String, new_value, new_max:bool)->void:
	match parameter_name:
		"health":
			if new_max:
				_health_bar.max_value = new_value
			_health_bar.value = new_value
		"scrap":
			_scrap = new_value
			_scrap_label.text = str(_scrap)
			emit_signal("update_scrap", _scrap)


func _on_UpgradeContainer_upgrade_system(system_name:String, scrap_reduction:int)->void:
	_scrap -= scrap_reduction
	_scrap_label.text = str(_scrap)
	emit_signal("update_scrap", _scrap)
	emit_signal("upgrade_system", system_name)
