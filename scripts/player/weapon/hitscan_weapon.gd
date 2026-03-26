class_name HitScanWeapon
extends Node3D


@export_group("settings")
@export var weapon_model: Node3D
@export var weapon_strategy: WeaponStrategy
@export var fire_rate := 14.0
@export_group("effects")
@export var muzzel_flash: GPUParticles3D
@export var sparks: PackedScene
@export_group("ammo managers")
@export var ammo_type: AmmoType.Type
@export var ammo_manager: AmmoManager
@export var energy_manager: EnergyManager
@export_group("components")
@export var input_handler: InputHandler
@export var hitscan_damage: HitScanDamageTarget
@export var hitscan_animation: HitScanAnimation
@export var hitscan_effect: HitScanEffects
@export_group("bus")
@export var camera_shake_bus: CameraShakeBus
@export var ammo_bus: AmmoBus
@export_subgroup("camera shake intensity")
@export var camera_shake_intensity := 2.0

var weapon_model_original_position := Vector3.ZERO
var accumulate_recoil := Vector3.ZERO
var one_shot := false
var ammo_count: int:
	get:
		if not ammo_manager:
			return 0

		return ammo_manager.count(ammo_type)
var energy_ratio: float:
	get:
		if not energy_manager:
			return 0.0

		return energy_manager.ratio

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var shoot_cast: RayCast3D = $ShootCast


func _ready() -> void:
	weapon_model_original_position = weapon_model.position

	cooldown_timer.wait_time = 1.0 / fire_rate

	input_handler.shoot_pressed.connect(func() -> void: one_shot = true)
	input_handler.shoot_released.connect(func() -> void: one_shot = false)


func _process(delta: float) -> void:
	if weapon_strategy:
		var shot_fired := weapon_strategy.shoot(self, delta)

		if shot_fired:
			shoot_cast.force_raycast_update()

			cooldown_timer.start()
			camera_shake_bus.emit_shake(camera_shake_intensity)

			hitscan_effect.restart_muzzel_flash()
			hitscan_animation.apply_recoil_animation()

			if shoot_cast.is_colliding():
				hitscan_effect.add_hit_effect(shoot_cast.get_collision_point())
				hitscan_damage.apply_damage_to_target(shoot_cast.get_collider())


func _add_hit_effect() -> void:
	if not shoot_cast.is_colliding():
		return

	var hit_spark := sparks.instantiate() as GPUParticles3D
	if hit_spark:
		get_tree().current_scene.add_child(hit_spark)
		hit_spark.global_position = shoot_cast.get_collision_point()


# region [has_method]

func unequip() -> void:
	visible = false
	set_process(false)


func equip() -> void:
	visible = true
	set_process(true)


func report_switched() -> void:
	weapon_strategy.on_switched(self)

# endregion
