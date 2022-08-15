extends CanvasLayer

onready var _health_bar = $"%Health" as ProgressBar
onready var _scrap_label = $"%Scrap" as Label


func _on_Main_player_update_hud(parameter_name:String, new_value, new_max:bool)->void:
	match parameter_name:
		"health":
			if new_max:
				_health_bar.max_value = new_value
			_health_bar.value = new_value
		"scrap":
			_scrap_label.text = str(new_value)
