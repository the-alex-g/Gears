extends VBoxContainer

signal path_selected(path_index)

# make sure these lists stay consistent with the ones in Robot.gd
enum WeaponPaths {DAMAGE, COOLDOWN}
enum DronePaths {DAMAGE, SPEED, HEALTH}

var system : String


func initialize(system_name:String)->void:
	# prepare for a choice to be made
	match system_name:
		"sword", "ranged":
			for x in WeaponPaths.size():
				_add_path(WeaponPaths.keys()[x])
			system = "weapon"
		"drone":
			for x in DronePaths.size():
				_add_path(DronePaths.keys()[x])
			system = "drone"
	visible = true


func _add_path(path_name:String)->void:
	# add an option button
	var button := Button.new()
	add_child(button)
	button.text = path_name.capitalize()
	# warning-ignore:return_value_discarded
	button.connect("pressed", self, "_on_button_pressed", [path_name], CONNECT_ONESHOT)


func _on_button_pressed(button_name:String)->void:
	# get index of chosen path
	var path_index = -1
	match system:
		"weapon":
			path_index = WeaponPaths.get(button_name)
		"drone":
			path_index = DronePaths.get(button_name)
	emit_signal("path_selected", path_index)
	# delete option buttons
	for button in get_children():
		button.queue_free()
	# hide
	visible = false
