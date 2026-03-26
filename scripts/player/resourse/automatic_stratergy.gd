class_name AutomaticFireStrategy
extends WeaponStrategy


## This strategy allows the weapon to fire continuously as long as the shoot button is held down, and there is ammo available.
func shoot(weapon: HitScanWeapon, _delta: float) -> bool:
	var can_fire := weapon.cooldown_timer.is_stopped()
	var is_shooting := weapon.input_handler.is_shooting
	var has_ammo := weapon.ammo_count > 0 
	
	if is_shooting and can_fire and has_ammo:
		weapon.ammo_manager.use_ammo(weapon.ammo_type, 1)
		return true

	return false


func on_switched(weapon: HitScanWeapon) -> void:
	if not weapon.ammo_bus:
		return
	weapon.ammo_bus.emit_weapon_switch(weapon.ammo_type, weapon.ammo_count)