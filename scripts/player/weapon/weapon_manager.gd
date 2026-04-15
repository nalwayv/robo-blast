class_name WeaponManager
extends Node3D

## A manager that loops over its children and activated / deactivates them based on player input.
## The children are expected to be weapons, but the manager doesn't enforce this.
## instead it uses duck typing like an interface to check if the child has the expected methods before calling them.
## [equip], [unequip] and [switched] are the expected methods that a child weapon should have, 
## but the manager will not throw an error if they are missing.

@export_group("components")
@export var input_handler: InputHandler

var current_equiped: int


func _ready() -> void:
	for child in get_children():
		if child.has_method("unequip"):
			child.unequip()

	_equip_weapon(current_equiped)
	
	input_handler.equip_pressed.connect(_equip_weapon)
	input_handler.equip_next.connect(_equip_next)
	input_handler.equip_previous.connect(_equip_previous)
	

func _is_valid_weapon_index(weapon_index: int) -> bool:
	return weapon_index >= 0 and weapon_index < get_child_count()

	
func _equip_weapon(weapon_index: int) -> void:
	if not _is_valid_weapon_index(weapon_index):
		return

	var old_weapon := get_child(current_equiped)
	if old_weapon.has_method("unequip"):
		old_weapon.unequip()
	
	current_equiped = weapon_index
	
	var new_weapon := get_child(current_equiped)
	if new_weapon.has_method("equip"):
		new_weapon.equip()

	if new_weapon.has_method("switched"):
		new_weapon.switched()


func _equip_previous() -> void:
	_equip_weapon(wrapi(current_equiped - 1, 0, get_child_count()))


func _equip_next() -> void:
	_equip_weapon(wrapi(current_equiped + 1, 0, get_child_count()))
