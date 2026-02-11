class_name WeaponHandler
extends Node3D

const DEAULT_FIRST_WEAPON := 0
const DEAULT_SECOND_WEAPON := 1

# used in:
#	AmmoPresenter
signal weapon_switched(weapon: HitScanWeapon)


var current_weapon_idx := 0


func _ready() -> void:
	equip_weapon(current_weapon_idx)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equip_weapon_1"):
		equip_weapon(DEAULT_FIRST_WEAPON)
		
	if event.is_action_pressed("equip_weapon_2"):
		equip_weapon(DEAULT_SECOND_WEAPON)
		
	if event.is_action_pressed("equip_next_weapon"):
		equip_next()
		
	if event.is_action_pressed("equip_previous_weapon"):
		equip_previous()


func is_valid_weapon_index(weapon_index: int) -> bool:
	return weapon_index >= 0 and weapon_index < get_child_count()

	
## set selected weapon to active and deactivate the rest.
func equip_weapon(weapon_index: int) -> void:
	if not is_valid_weapon_index(weapon_index):
		return
	
	# set current weapon active and deactivate the rest
	current_weapon_idx = weapon_index
	
	for i in get_child_count():
		var child := get_child(i)
		if child is HitScanWeapon:
			if i == current_weapon_idx:
				child.visible = true
				child.set_process(true)
				weapon_switched.emit(child)
			else:
				child.visible = false
				child.set_process(false)


## set selected weapon to previous weapon in child index.
func equip_previous() -> void:
	equip_weapon(wrapi(current_weapon_idx - 1, 0, get_child_count()))


## set selected weapon to next weapon in child index.
func equip_next() -> void:
	equip_weapon(wrapi(current_weapon_idx + 1, 0, get_child_count()))
