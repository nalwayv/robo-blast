class_name ManualSwitchedStrategy
extends WeaponSwitchedStrategy


func report_switch(weapon: HitScanWeapon) -> void:
    if not weapon.ammo_bus:
        return
    
    weapon.ammo_bus.emit_weapon_switch(weapon.ammo_type, weapon.ammo_count)

