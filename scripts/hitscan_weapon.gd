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
@export_group("groups")
@export var shakable: Node3D ## node that is with group shakable to able to call add_shake

var model_position := Vector3.ZERO
var can_shoot := false

@onready var ray_cast: RayCast3D = $RayCast3D
@onready var cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	cooldown_timer.wait_time = 1.0 / fire_rate
	model_position = weapon_model.position
	
	input_handler.shoot_pressed.connect(func(): can_shoot = true)
	input_handler.shoot_released.connect(func(): can_shoot = false)


func _process(delta: float) -> void:
	var can_fire := cooldown_timer.is_stopped()
	
	if is_automatic:
		if input_handler.is_shooting and can_fire:
			fire_weapon()
	else:
		if can_shoot and can_fire:
			fire_weapon()
			can_shoot = false
			
	_recoil_animation(delta)


func fire_weapon() -> void:
	if ammo_handler:
		if not ammo_handler.has_ammo(ammo_type):
			return
		ammo_handler.use_ammo(ammo_type)
	
	cooldown_timer.start(1.0 / fire_rate)
	muzzel_flash.restart()
	weapon_model.position.z += recoil_amount
	
	if shakable and shakable.is_in_group("shakable"):
		shakable.apply_shake(recoil_impule)
		
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		_spawn_hit_effect()
		_apply_damage_to_target()


func _spawn_hit_effect() -> void:
	var hit_spark := sparks.instantiate()
	add_child(hit_spark)
	hit_spark.global_position = ray_cast.get_collision_point()


func _apply_damage_to_target() -> void:
	var node := ray_cast.get_collider() as Node
	while node:
		if node is CharacterBody3D and node.is_in_group("health"):
			var health := node.get_node_or_null("%Health") as Health
			if health:
				health.hitpoints -= weapon_damage
				return
		node = node.get_parent()


func _recoil_animation(delta: float) -> void:
	weapon_model.position = weapon_model.position.lerp(model_position, recoil_speed * delta)
