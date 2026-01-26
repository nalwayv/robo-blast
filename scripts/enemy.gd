class_name Enemy
extends CharacterBody3D

const SPEED: float = 2.0

@export var attack_damage: int = 20
@export var fov: float = 90.0
@export var fov_range: float = 5.0
@export var aggro_range: float = 5.0

var provoked: bool = false
var attack_range: float = 2.0;

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player := get_tree().get_first_node_in_group("player") as Player


func _ready() -> void:
	# connect up health component signals
	if has_meta("Health"):
		var health := get_meta("Health") as Health
		health.died.connect(queue_free)
		health.damaged.connect(on_hit)


func _process(_delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var direction: Vector3 = global_position.direction_to(next_path_position)
	var distance: float = global_position.distance_to(player.global_position)
	
	if distance <= aggro_range and is_player_within_fov_dot():
		provoked = true
	
	if provoked and distance <= attack_range:
		animation_player.play("attack")
		
	if direction:
		look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()


func look_at_target(target: Vector3) -> void:
	look_at(global_position + Vector3(target.x, 0.0, target.z))


func attack() -> void:
	# NOTE - funtion is being called within attack animation on AnimationPlayer
	if player.has_meta("Health"):
		var health := player.get_meta("Health") as Health
		health.hitpoints -= attack_damage
		printt("attack! player health is now", health.hitpoints)


func on_hit() -> void:
	provoked = true


## using local_space to check if player is within field of view
#func is_player_within_fov_local() -> bool:
#	var local := to_local(player.global_position)
#	
#	if -local.z < 0.0:
#		return false
#		
#	var half_fov := deg_to_rad(fov * 0.5)
#	var h_angle := absf(atan2(local.x, -local.z))
#	var v_angle := absf(atan2(local.y, -local.z))
#
#	return h_angle <= half_fov and v_angle <= half_fov


## using dot product to check if player is within field of view
func is_player_within_fov_dot() -> bool:
	var forward := -global_basis.z
	var half_fov := deg_to_rad(fov * 0.5)
	var direction_to := global_position.direction_to(player.global_position)
	
	return forward.dot(direction_to) > cos(half_fov)
