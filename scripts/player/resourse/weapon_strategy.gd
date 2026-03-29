class_name WeaponStrategy
extends Resource

@export var ammo_bus: AmmoBus


func shoot(_weapon: HitScanWeapon, _delta: float) -> bool:
    return false


func on_switched(_weapon: HitScanWeapon) -> void:
    pass