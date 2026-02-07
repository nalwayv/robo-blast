class_name HitScanWeapon
extends Node3D

const RAY_LENGTH := 100


@export_range(1.0, 20.0) var fire_rate := 14.0
@export var recoil := 0.1
@export var recoil_shake := 0.07
@export var weapon_damage := 10
@export var is_automatic := true
@export var weapon_node: Node3D
@export var muzzel_flash: GPUParticles3D
@export var sparks: PackedScene
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.AmmoType
var recoil_speed := 10.0

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var original_weapon_position: Vector3 = weapon_node.position


func _ready() -> void:
	cooldown_timer.wait_time = 1.0 / fire_rate


func _process(delta: float) -> void:
	var can_fire := cooldown_timer.is_stopped()
	if is_automatic:
		if Input.is_action_pressed("fire_weapon") and can_fire:
			fire_weapon()
	else:
		if Input.is_action_just_pressed("fire_weapon") and can_fire:
			fire_weapon()
	
	recoil_animation(delta)


func fire_weapon() -> void:
	if ammo_handler:
		if not ammo_handler.has_ammo(ammo_type):
			return
		ammo_handler.use_ammo(ammo_type)
	
	cooldown_timer.start(1.0 / fire_rate)
	muzzel_flash.restart()
	weapon_node.position.z += recoil
	
	var camera := owner.get_node_or_null("CameraRig") as CameraRig
	if camera:
		camera.apply_shake(recoil, deg_to_rad(10.0))
	
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		return
		
	spawn_hit_effect()
	apply_damage_to_target()


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
				#printt("fire weapon! enemy health is now", health.hitpoints)
				return
		node = node.get_parent()


func recoil_animation(delta: float) -> void:
	weapon_node.position = weapon_node.position.lerp(original_weapon_position, recoil_speed * delta)
	
