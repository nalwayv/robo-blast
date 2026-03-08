class_name HitScanWeapon
extends Node3D

const RAY_LENGTH := 100

@export var weapon_model: Node3D
@export_group("settings")
@export var fire_rate := 14.0
@export var damage := 10
@export var is_automatic := true
@export var recoil_amount := 0.1
@export var recoil_speed := 10.0
@export var camera_shake_intensity := 2.0
@export_group("effects")
@export var muzzel_flash: GPUParticles3D
@export var sparks: PackedScene
@export_group("ammo")
@export var ammo_type: AmmoType.Type
@export var ammo_handler: AmmoHandler
@export_group("components")
@export var input_handler: InputHandler
@export_group("resources")
@export var camera_shake_bus: CameraShakeBus

var model_original_position := Vector3.ZERO
var single_shot := false

@onready var shoot_cast: RayCast3D = $ShootCast
@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	cooldown_timer.wait_time = 1.0 / fire_rate
	model_original_position = weapon_model.position
	
	input_handler.shoot_pressed.connect(func(): single_shot = true)
	input_handler.shoot_released.connect(func(): single_shot = false)


func _process(delta: float) -> void:
	var can_fire := cooldown_timer.is_stopped()
	
	if is_automatic:
		if input_handler.is_shooting and can_fire:
			fire_weapon()
	else:
		if single_shot and can_fire:
			fire_weapon()
			single_shot = false
			
	_recoil_animation(delta)


func fire_weapon() -> void:
	if ammo_handler.count(ammo_type) == 0:
		return
		
	ammo_handler.use_ammo(ammo_type)
	
	cooldown_timer.start()
	muzzel_flash.restart()

	weapon_model.position.z += recoil_amount
	
	camera_shake_bus.emit_shake(camera_shake_intensity)
		
	shoot_cast.force_raycast_update()

	_apply_damage_to_target()
	_instantiate_effect()


func _instantiate_effect() -> void:
	if not shoot_cast.is_colliding():
		return

	var hit_spark := sparks.instantiate() as GPUParticles3D
	if hit_spark:
		add_child(hit_spark)
		hit_spark.global_position = shoot_cast.get_collision_point()


func _apply_damage_to_target() -> void:
	if not shoot_cast.is_colliding():
		return

	var collider := shoot_cast.get_collider()
	if collider is CharacterBody3D:
		var health := collider.get_node_or_null("%Health") as Health
		if health:
			health.hitpoints -= damage


func _recoil_animation(delta: float) -> void:
	weapon_model.position = weapon_model.position.lerp(model_original_position, recoil_speed * delta)
