
class_name AmmoManager
extends Node

signal ammo_updated(type: AmmoType.Type)

@export_group("starting ammo")
@export var ammo_storage: Dictionary[AmmoType.Type, int] = {}


func _ready() -> void:
	for key: AmmoType.Type in ammo_storage:
		ammo_storage[key] = absi(ammo_storage[key])


func add_ammo(ammo_type: AmmoType.Type, amount: int) -> void:
	ammo_storage[ammo_type] += amount
	ammo_updated.emit(ammo_type)


func use_ammo(ammo_type: AmmoType.Type, amount: int) -> void:
	ammo_storage[ammo_type] = maxi(0, ammo_storage[ammo_type] - amount)
	ammo_updated.emit(ammo_type)


func count(ammo_type: AmmoType.Type) -> int:
	return ammo_storage[ammo_type]
