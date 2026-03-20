class_name EnergyFireStrategy
extends WeaponFireStrategy


## This strategy consumes energy to shoot, and regenerates energy when not shooting.
func shoot(weapon: HitScanWeapon, delta: float) -> bool:
	var is_shooting := weapon.input_handler.is_shooting
	var can_shoot := weapon.cooldown_timer.is_stopped()
	
	if is_shooting and can_shoot:
		if weapon.energy_manager.consume(delta):
			weapon.cooldown_timer.start()
			return true
	else:
		weapon.energy_manager.begin_regen_timer()

	weapon.energy_manager.regenerate(delta)
	return false
