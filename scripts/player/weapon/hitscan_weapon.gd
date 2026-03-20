class_name HitScanWeapon
extends Node3D

const RECOIL_LENGTH_LIMIT := 0.2

@export_group("settings")
@export var weapon_model: Node3D
@export var weapon_fire_strategy: WeaponFireStrategy
@export var weapon_switched_strategy: WeaponSwitchedStrategy
@export var fire_rate := 14.0
@export var damage := 10
@export var recoil_force := 0.1
@export var recoil_rest_sharpness := 10.0
@export var recoil_sharpness := 50.0
@export var camera_shake_intensity := 2.0
@export_group("effects")
@export var muzzel_flash: GPUParticles3D
@export var sparks: PackedScene
@export_group("ammo managers")
@export var ammo_type: AmmoType.Type
@export var ammo_manager: AmmoManager
@export var energy_manager: EnergyManager
@export_group("components")
@export var input_handler: InputHandler
@export_group("bus")
@export var camera_shake_bus: CameraShakeBus
@export var ammo_bus: AmmoBus

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
	if weapon_fire_strategy:
		var shot_fired := weapon_fire_strategy.shoot(self, delta)

		if shot_fired:
			cooldown_timer.start()
			muzzel_flash.restart()
			camera_shake_bus.emit_shake(camera_shake_intensity)
			_add_hit_effect()
			_damage_target()
			_apply_recoil()

		_update_recoil(delta)


func _add_hit_effect() -> void:
	if not shoot_cast.is_colliding():
		return

	var hit_spark := sparks.instantiate() as GPUParticles3D
	if hit_spark:
		get_tree().current_scene.add_child(hit_spark)
		hit_spark.global_position = shoot_cast.get_collision_point()


func _damage_target() -> void:
	if not shoot_cast.is_colliding():
		return

	var collider := shoot_cast.get_collider()
	if collider is CharacterBody3D:
		var health := collider.get_node_or_null("%Health") as Health
		if health:
			health.hitpoints -= damage


func _update_recoil(delta: float) -> void:
	if weapon_model.position.z <= accumulate_recoil.z * 0.99:
		weapon_model.position = weapon_model.position.lerp(
			accumulate_recoil,
			recoil_sharpness * delta)
	else:
		weapon_model.position = weapon_model.position.lerp(
			weapon_model_original_position, 
			recoil_rest_sharpness * delta)

		accumulate_recoil = weapon_model.position


func _apply_recoil() -> void:
	accumulate_recoil += Vector3.BACK * recoil_force
	accumulate_recoil = accumulate_recoil.limit_length(RECOIL_LENGTH_LIMIT)


# region [has_method]

func unequip() -> void:
	visible = false
	set_process(false)


func equip() -> void:
	visible = true
	set_process(true)


func report_switched() -> void:
	weapon_switched_strategy.report_switch(self)

# endregion
