class_name AmmoHandler
extends Node

signal ammo_updated(type: AmmoType.Type, amount: int)

@export_group("ammo")
@export var small_ammo_count := 25
@export var large_ammo_count := 5

var ammo_storage: Dictionary[AmmoType.Type, int] = {}


func _ready() -> void:
	ammo_storage[AmmoType.Type.SMALL] = maxi(0, small_ammo_count)
	ammo_storage[AmmoType.Type.LARGE] = maxi(0, large_ammo_count)


func add_ammo(ammo_type: AmmoType.Type, amount: int) -> void:
	ammo_storage[ammo_type] += amount
	ammo_updated.emit(ammo_type, ammo_storage[ammo_type])


func use_ammo(ammo_type: AmmoType.Type, amount: int = 1) -> void:
	if count(ammo_type) == 0:
		return
		
	ammo_storage[ammo_type] = maxi(0, ammo_storage[ammo_type] - amount)
	ammo_updated.emit(ammo_type, ammo_storage[ammo_type])


func count(ammo_type: AmmoType.Type) -> int:
	return ammo_storage[ammo_type]