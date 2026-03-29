class_name HitScanWeapon
extends Node3D

@export_group("settings")
@export var weapon_model: Node3D
@export var weapon_strategy: WeaponStrategy
@export var fire_rate := 14.0
@export_group("ammo managers")
@export var ammo_type: AmmoType.Type
@export var ammo_manager: AmmoManager
@export var energy_manager: EnergyManager
@export_group("components")
@export var input_handler: InputHandler
@export var weapon_damage: WeaponDamage
@export var weapon_animation: WeaponAnimation
@export var weapon_effects: WeaponEffects
@export_group("resource")
@export var camera_bus: CameraBus
@export_subgroup("camera shake")
@export var camera_shake := 2.0

var one_shot: bool
var ammo_count: int:
	get:
		if not ammo_manager:
			return 0

		return ammo_manager.count(ammo_type)
var energy_ratio: float:
	get:
		if not energy_manager:
			return 0.0

		return energy_manager.energy_ratio

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var shoot_cast: RayCast3D = $ShootCast


func _ready() -> void:
	cooldown_timer.wait_time = 1.0 / fire_rate

	input_handler.shoot_pressed.connect(func() -> void: one_shot = true)
	input_handler.shoot_released.connect(func() -> void: one_shot = false)


func _process(delta: float) -> void:
	if weapon_strategy:
		var shot_fired := weapon_strategy.shoot(self, delta)

		if shot_fired:
			shoot_cast.force_raycast_update()

			cooldown_timer.start()
			camera_bus.emit_shake(camera_shake)

			weapon_effects.emmit_muzzel_flash()
			weapon_animation.apply_recoil_animation()

			if shoot_cast.is_colliding():
				weapon_effects.add_hit_effect(shoot_cast.get_collision_point())
				weapon_damage.apply_damage_to_target(shoot_cast.get_collider())


# region [has_method]

func unequip() -> void:
	visible = false
	set_process(false)


func equip() -> void:
	visible = true
	set_process(true)


func switched() -> void:
	weapon_strategy.on_switched(self)

# endregion
