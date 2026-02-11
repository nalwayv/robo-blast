class_name HitScanWeapon
extends Node3D

const RAY_LENGTH := 100

@export_group("weapon settings")
@export_range(1.0, 20.0) var fire_rate := 14.0
@export var weapon_damage := 10
@export var is_automatic := true
@export var weapon_model: Node3D
@export_group("recoil")
@export var recoil_amount := 0.1
@export var recoil_speed := 10.0
@export_range(1.0, 3.0) var recoil_impule := 2.0
@export_group("effects")
@export var muzzel_flash: GPUParticles3D
@export var sparks: PackedScene
@export_group("ammo")
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.AmmoType
@export_group("components")
@export var input_handler: InputHandler
@export var camera_controler: CameraControler

var model_position := Vector3.ZERO

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	cooldown_timer.wait_time = 1.0 / fire_rate
	model_position = weapon_model.position
	

func _process(delta: float) -> void:
	var can_fire := cooldown_timer.is_stopped()
	if is_automatic:
		if input_handler.is_shooting and can_fire:
			fire_weapon()
	else:
		# TODO: current setup means you can hold doen fire and use like its automatic
		if input_handler.is_shooting and can_fire:
			fire_weapon()
	
	recoil_animation(delta)


func fire_weapon() -> void:
	if ammo_handler:
		if not ammo_handler.has_ammo(ammo_type):
			return
		ammo_handler.use_ammo(ammo_type)
	
	cooldown_timer.start(1.0 / fire_rate)
	muzzel_flash.restart()
	weapon_model.position.z += recoil_amount
	
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		return
		
	spawn_hit_effect()
	apply_damage_to_target()
	camera_controler.player_camera.apply_impule(recoil_impule)


func spawn_hit_effect() -> void:
	var hit_spark := sparks.instantiate()
	add_child(hit_spark)
	hit_spark.global_position = ray_cast.get_collision_point()


func apply_damage_to_target() -> void:
	var node := ray_cast.get_collider() as Node
	while node:
		if node is CharacterBody3D and node.is_in_group("health"):
			var health := node.get_node_or_null("%Health") as Health
			if health:
				health.hitpoints -= weapon_damage
				return
		node = node.get_parent()


func recoil_animation(delta: float) -> void:
	weapon_model.position = weapon_model.position.lerp(model_position, recoil_speed * delta)
