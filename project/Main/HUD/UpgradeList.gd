extends VBoxContainer

signal upgrade_system(system_name, scrap_reduction, path)

enum Upgrades {DRONE, MOVEMENT, RANGED, SHIELD, SWORD}

const REPAIR_THRESHOLD := 5
const UPGRADE_STEP := 10
const NEW_SYSTEM := 30

onready var _armor_upgrade = $"%ArmorUpgradeButton" as Button
onready var _drone_upgrade = $"%DroneUpgradeButton" as Button
onready var _movement_upgrade = $"%MovementUpgradeButton" as Button
onready var _ranged_upgrade = $"%RangedUpgradeButton" as Button
onready var _shield_upgrade = $"%ShieldUpgradeButton" as Button
onready var _sword_upgrade = $"%SwordUpgradeButton" as Button
onready var _upgrade_path_widget = $UpgradePathWidget as VBoxContainer

var _drone_equipped := false
var _shield_equipped := false
var _ranged_equipped := false
var _upgrades := [0, 0, 0, 0, 0]


func _on_ArmorUpgradeButton_pressed()->void:
	emit_signal("upgrade_system", "armor", REPAIR_THRESHOLD, 0)


func _on_DroneUpgradeButton_pressed()->void:
	var cost := 0
	if _drone_equipped:
		cost = (_upgrades[Upgrades.DRONE] + 1) * UPGRADE_STEP
		_upgrades[Upgrades.DRONE] += 1
	else:
		cost = NEW_SYSTEM
		_drone_equipped = true
	_upgrade_path_widget.initialize("drone")
	var path = yield(_upgrade_path_widget, "path_selected") as int
	emit_signal("upgrade_system", "drone", cost, path)


func _on_MovementUpgradeButton_pressed()->void:
	_upgrades[Upgrades.MOVEMENT] += 1
	emit_signal("upgrade_system", "movement", _upgrades[Upgrades.MOVEMENT] * UPGRADE_STEP, 0)


func _on_RangedUpgradeButton_pressed()->void:
	var cost := 0
	if _ranged_equipped:
		cost = (_upgrades[Upgrades.RANGED] + 1) * UPGRADE_STEP
		_upgrades[Upgrades.RANGED] += 1
	else:
		cost = NEW_SYSTEM
		_ranged_equipped = true
	_upgrade_path_widget.initialize("ranged")
	var path = yield(_upgrade_path_widget, "path_selected") as int
	emit_signal("upgrade_system", "ranged", cost, path)


func _on_ShieldUpgradeButton_pressed()->void:
	var cost := 0
	if _shield_equipped:
		cost = (_upgrades[Upgrades.SHIELD] + 1) * UPGRADE_STEP
		_upgrades[Upgrades.SHIELD] += 1
	else:
		cost = NEW_SYSTEM
		_shield_equipped = true
	emit_signal("upgrade_system", "shield", cost)


func _on_SwordUpgradeButton_pressed()->void:
	_upgrades[Upgrades.SWORD] += 1
	_upgrade_path_widget.initialize("sword")
	var path = yield(_upgrade_path_widget, "path_selected") as int
	emit_signal("upgrade_system", "sword", _upgrades[Upgrades.SWORD] * UPGRADE_STEP, path)


func _on_HUD_update_scrap(new_value:int)->void:
	_armor_upgrade.visible = false
	_drone_upgrade.visible = false
	_movement_upgrade.visible = false
	_ranged_upgrade.visible = false
	_shield_upgrade.visible = false
	_sword_upgrade.visible = false
	if new_value >= REPAIR_THRESHOLD:
		_armor_upgrade.visible = true
	if new_value >= NEW_SYSTEM:
		if not _drone_equipped:
			_drone_upgrade.visible = true
		if not _shield_equipped:
			_shield_upgrade.visible = true
		if not _ranged_equipped:
			_ranged_upgrade.visible = true
	for x in _upgrades.size():
		var value = _upgrades[x] as int
		if value < 3:
			if new_value >= (value + 1) * UPGRADE_STEP:
				match x:
					Upgrades.DRONE:
						if _drone_equipped:
							_drone_upgrade.visible = true
					Upgrades.MOVEMENT:
						_movement_upgrade.visible = true
					Upgrades.RANGED:
						if _ranged_equipped:
							_ranged_upgrade.visible = true
					Upgrades.SHIELD:
						if _shield_equipped:
							_shield_upgrade.visible = true
					Upgrades.SWORD:
						_sword_upgrade.visible = true
