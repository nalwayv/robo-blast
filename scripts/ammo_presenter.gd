class_name AmmoPresenter
extends Node

@export var ammo_handler: AmmoHandler
@export var weapon_handler: WeaponHandler
@export var ammo_label: Label

var current_active_ammo_type: AmmoHandler.AmmoType


func _ready() -> void:
	ammo_handler.ammo_updated.connect(on_ammo_updated)
	weapon_handler.weapon_switched.connect(on_weapon_switched)
	
	var child := weapon_handler.get_child(weapon_handler.current_weapon)
	if child is HitScanWeapon:
		on_weapon_switched(child)


func on_weapon_switched(weapon: HitScanWeapon) -> void:
	current_active_ammo_type = weapon.ammo_type
	update_label(ammo_handler.get_ammo_count(weapon.ammo_type))


func on_ammo_updated(ammo_type:AmmoHandler.AmmoType, amount: int) -> void:
	# only update text for current active weapon
	if ammo_type != current_active_ammo_type:
		return
	update_label(amount)


func update_label(amount: int) -> void:
	ammo_label.text = str(amount)
