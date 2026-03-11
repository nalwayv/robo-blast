class_name WeaponController # rename to weapon manager
extends Node3D

signal weapon_switched(ammo_type: AmmoType.Type)

@export var input_handler: InputHandler

var current_equiped := 0

enum WeaponState {
	UP, DOWN, UP_NEW, DOWN_PREV,
}

# NOTES:
# @export list os weapons []
# list slots []
# add weapon func:
	# if has_weapon then ignore
	# for i in weapon_slots:
		# add to empty slot:
			# add_child
			# hide and set process to false
			# set slot[i] to child
			# add weapon emit


func _ready() -> void:
	_equip_weapon(current_equiped)
	
	input_handler.equip_preessed.connect(_equip_weapon)
	input_handler.equip_next.connect(_equip_next)
	input_handler.equip_previous.connect(_equip_previous)


func _is_valid_weapon_index(weapon_index: int) -> bool:
	return weapon_index >= 0 and weapon_index < get_child_count()

	
func _equip_weapon(weapon_index: int) -> void:
	if not _is_valid_weapon_index(weapon_index):
		return
	
	current_equiped = weapon_index
	for i in get_child_count():
		var child := get_child(i)
		if child is HitScanWeapon:
			if i == current_equiped:
				child.visible = true
				child.set_process(true)

				weapon_switched.emit(child.ammo_type)
			else:
				child.visible = false
				child.set_process(false)


func _equip_previous() -> void:
	_equip_weapon(wrapi(current_equiped - 1, 0, get_child_count()))


func _equip_next() -> void:
	_equip_weapon(wrapi(current_equiped + 1, 0, get_child_count()))
