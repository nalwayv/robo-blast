class_name ManualFireStrategy
extends WeaponFireStrategy

## This strategy allows the weapon to fire only once per shoot button press, and requires ammo to shoot.
func shoot(weapon: HitScanWeapon, _delta: float) -> bool:
	var can_fire := weapon.cooldown_timer.is_stopped()
	var is_shooting := weapon.input_handler.is_shooting
	var has_ammo := weapon.ammo_count > 0 

	if is_shooting and can_fire and has_ammo and weapon.one_shot:
		weapon.one_shot = false
		weapon.ammo_manager.use_ammo(weapon.ammo_type, 1)
		return true

	return false
