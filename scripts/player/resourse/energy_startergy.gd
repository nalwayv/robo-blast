class_name EnergyStrategy
extends WeaponStrategy


## This strategy consumes energy to shoot, and regenerates energy when not shooting.
func shoot(weapon: HitScanWeapon, delta: float) -> bool:
	var is_shooting := weapon.input_handler.is_shooting
	var can_shoot := weapon.cooldown_timer.is_stopped()
	
	if is_shooting and can_shoot:
		if weapon.energy_manager.consume_energy(delta):
			weapon.cooldown_timer.start()
			return true
	else:
		weapon.energy_manager.start_recharge_timer()

	weapon.energy_manager.recharge_energy(delta)
	return false


func on_switched(weapon: HitScanWeapon) -> void:
	ammo_bus.emit_energy_switched(weapon.energy_ratio)