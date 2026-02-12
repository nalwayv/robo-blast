class_name AmmoPresenter
extends Node

@export_group("label")
@export var ammo_label: Label
@export_group("componenets")
@export var weapon_handler: WeaponHandler
@export var ammo_handler: AmmoHandler

var current_active_ammo_type: AmmoHandler.AmmoType


func _ready() -> void:
	ammo_handler.ammo_updated.connect(_on_ammo_updated)
	weapon_handler.weapon_switched.connect(_on_weapon_switched)


func _on_weapon_switched(weapon: HitScanWeapon) -> void:
	current_active_ammo_type = weapon.ammo_type
	ammo_label.text = str(ammo_handler.get_ammo_count(weapon.ammo_type))


func _on_ammo_updated(ammo_type: AmmoHandler.AmmoType, amount: int) -> void:
	if ammo_type == current_active_ammo_type:
		ammo_label.text = str(amount)
