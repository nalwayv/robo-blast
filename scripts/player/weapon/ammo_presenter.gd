class_name AmmoPresenter
extends Node

@export_group("label")
@export var ammo_label: Label
@export_group("componenets")
@export var weapon_manager: WeaponManager
@export var ammo_manager: AmmoManager
@export var energy_manager: EnergyManager


var active_weapon_ammo_type := AmmoType.Type.UNDEFINED


func _ready() -> void:
	ammo_manager.ammo_updated.connect(_on_ammo_updated)
	energy_manager.energy_updated.connect(_on_energy_updated)
	weapon_manager.weapon_switched.connect(_on_weapon_switched)


func _on_ammo_updated(ammo_type: AmmoType.Type) -> void:
	if ammo_type == active_weapon_ammo_type:
		var amount := ammo_manager.count(ammo_type)
		ammo_label.text = str(amount)


func _on_energy_updated() -> void:
	ammo_label.text = "%.0f" % (energy_manager.get_ratio() * 100.0)


func _on_weapon_switched(weapon: HitScanWeapon) -> void:
	if weapon.weapon_type == WeaponType.Type.ENERGY:
		ammo_label.text = "%.0f" % (energy_manager.get_ratio() * 100.0)
	else:
		active_weapon_ammo_type = weapon.ammo_type
		
		var ammo_count := ammo_manager.count(weapon.ammo_type)
		ammo_label.text = str(ammo_count)
	
		

