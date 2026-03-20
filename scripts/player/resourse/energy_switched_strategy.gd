class_name EnergySwitchedStrategy
extends WeaponSwitchedStrategy


func report_switch(weapon: HitScanWeapon) -> void:
    if not weapon.ammo_bus:
        return

    weapon.ammo_bus.emit_energy_switched(weapon.energy_ratio)
