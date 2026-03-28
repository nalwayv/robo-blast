class_name AmmoPresenter
extends Node

@export_group("label")
@export var ammo_label: Label
@export_group("ammo bus")
@export var ammo_bus: AmmoBus

func _ready() -> void:
	ammo_bus.ammo_updated.connect(_on_ammo_updated)
	ammo_bus.energy_updated.connect(_on_energy_updated)
	ammo_bus.weapon_switched.connect(_on_weapon_switched)
	ammo_bus.energy_switched.connect(_on_energy_switched)


func _on_ammo_updated(count: int, is_active: bool) -> void:
	if is_active:
		ammo_label.text = str(count)


func _on_energy_updated(ratio: float) -> void:
	ammo_label.text = "%.0f" % (ratio * 100.0)


func _on_weapon_switched(count: int) -> void:
	ammo_label.text = str(count)


func _on_energy_switched(ratio: float) -> void:
	ammo_label.text = "%.0f" % (ratio * 100.0)