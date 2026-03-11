class_name AmmoPresenter
extends Node

@export_group("label")
@export var ammo_label: Label
@export_group("componenets")
@export var weapon_controller: WeaponController
@export var ammo_handler: AmmoHandler

var active_weapon_ammo_type := AmmoType.Type.UNDEFINED


func _ready() -> void:
	ammo_handler.ammo_updated.connect(_on_ammo_updated)
	weapon_controller.weapon_switched.connect(_on_weapon_switched)


func _on_ammo_updated(ammo_type: AmmoType.Type, amount: int) -> void:
	if active_weapon_ammo_type == AmmoType.Type.UNDEFINED:
		active_weapon_ammo_type = ammo_type
		ammo_label.text = str(amount)
	elif ammo_type == active_weapon_ammo_type:
		ammo_label.text = str(amount)


func _on_weapon_switched(ammo_type: AmmoType.Type) -> void:
	active_weapon_ammo_type = ammo_type
	ammo_label.text = str(ammo_handler.count(ammo_type))
