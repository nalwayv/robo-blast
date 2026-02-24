class_name AmmoHandler
extends Node

signal ammo_updated(type: AmmoType.Type, amount: int)


var ammo_storage: Dictionary[AmmoType.Type, int] = {
	AmmoType.Type.SMALL: 25,
	AmmoType.Type.LARGE: 5,
}


func add_ammo(ammo_type: AmmoType.Type, amount: int) -> void:
	ammo_storage[ammo_type] += amount
	ammo_updated.emit(ammo_type, ammo_storage[ammo_type])


func use_ammo(ammo_type: AmmoType.Type) -> void:
	if not has_ammo(ammo_type):
		return
		
	ammo_storage[ammo_type] -= 1
	ammo_updated.emit(ammo_type, ammo_storage[ammo_type])


func has_ammo(ammo_type: AmmoType.Type) -> bool:
	return ammo_storage[ammo_type] > 0


func get_ammo_count(ammo_type: AmmoType.Type) -> int:
	return ammo_storage[ammo_type]