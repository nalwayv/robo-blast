class_name AmmoHandler
extends Node

signal ammo_updated(type:AmmoType, amount: int)

enum AmmoType {
	REGULAR_BULLET,
	SMALL_BULLET, 
}

var ammo_storage: Dictionary[AmmoType, int] = {
	AmmoType.REGULAR_BULLET: 10,
	AmmoType.SMALL_BULLET: 60,
}


func add_ammo(ammo_type: AmmoType, amount: int) -> void:
	ammo_storage[ammo_type] += amount
	ammo_updated.emit(ammo_type, ammo_storage[ammo_type])


func use_ammo(ammo_type: AmmoType) -> void:
	if not has_ammo(ammo_type):
		return
		
	ammo_storage[ammo_type] -= 1
	ammo_updated.emit(ammo_type, ammo_storage[ammo_type])


func has_ammo(ammo_type: AmmoType) -> bool:
	return ammo_storage[ammo_type] > 0


func get_ammo_count(ammo_type: AmmoType) -> int:
	return ammo_storage[ammo_type]
