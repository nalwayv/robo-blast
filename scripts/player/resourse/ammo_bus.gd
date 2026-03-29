class_name AmmoBus 
extends Resource

signal ammo_updated(count: int, is_active: bool)
signal energy_updated(ratio: float)
signal weapon_switched(count: int)
signal energy_switched(ratio: float)


var active_ammo_type: AmmoType.Type = AmmoType.Type.UNDEFINED


# region [helper functions]
func emit_ammo_updated(type: AmmoType.Type, count: int) -> void:
    var is_active := type == active_ammo_type
    ammo_updated.emit(count, is_active)


func emit_energy_updated(ratio: float) -> void:
    energy_updated.emit(ratio)


func emit_weapon_switch(ammo_type: AmmoType.Type, count: int) -> void:
    active_ammo_type = ammo_type
    weapon_switched.emit(count)


func emit_energy_switched(ratio: float) -> void:
    energy_switched.emit(ratio)
# endregion