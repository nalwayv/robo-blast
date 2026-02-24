class_name EnemyController
extends CharacterBody3D

const MAX_TURN_ANGLE := deg_to_rad(60.0)
const EPSILON := 0.01

@export_group("movement")
@export var max_speed := 2.5
@export var stop_speed := 2.0
@export var acceleration := 10.0
@export var friction := 6.0
@export var min_turn_speed := 5.0
@export var max_turn_speed := 15.0
@export_group("field of view")
@export var aggro_range := 5.0
@export var fov := 90.0
@export var fov_range := 5.0
@export_group("attack")
@export var attack_range := 2.0
@export var attack_damage := 20
@export_group("components")
@export var health: Health
@export_group("debug")
@export var show_debug := false
@export var debug: Node3D

var provoked := false
var smooth_direction := 10.0
var movement_prediction_threshold := 0.33
var movement_prediction_time := 1.0
var current_direction := Vector3.FORWARD

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player := get_tree().get_first_node_in_group("player") as PlayerController


func _ready() -> void:
	health.died.connect(queue_free)
	health.damaged.connect(func(): provoked = true)

	if show_debug:
		debug.show_debug = true
		debug.fov = fov
		debug.fov_range = fov_range
		debug.aggro_range = aggro_range
		

func _process(_delta: float) -> void:
	if provoked:
		_update_prediction_target()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if provoked:
		var next_path_position := navigation_agent_3d.get_next_path_position()
		var direction := global_transform.origin.direction_to(next_path_position)

		current_direction = current_direction.lerp(direction, smooth_direction * delta)
		var wish_direction := Vector3(current_direction.x, 0.0, current_direction.z).normalized()

		_apply_friction(delta)
		_apply_accelerate(wish_direction, max_speed, delta)
		_apply_rotation(direction, delta)
	else:
		_apply_friction(delta)

	move_and_slide()

	var distance := global_transform.origin.distance_to(player.global_transform.origin)
	_update_is_provoked(distance)
	_check_can_attack(distance)


func _apply_rotation(direction: Vector3, delta: float) -> void:
	var target_yaw := atan2(-direction.x, -direction.z)
	var angle_diff := angle_difference(rotation.y, target_yaw)
	var turn_speed := max_turn_speed if absf(angle_diff) > MAX_TURN_ANGLE else min_turn_speed
	rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)


func attack() -> void:
	# NOTE - this is being called within AnimationPlayer "attack"
	var player_health := player.get_node_or_null("%Health") as Health
	if player_health:
		player_health.hitpoints -= attack_damage


func _update_is_provoked(distance: float):
	if distance <= aggro_range and _is_player_within_fov():
		provoked = true


func _check_can_attack(distance: float):
	if distance <= attack_range and provoked:
		animation_player.play("attack")


func _is_player_within_fov() -> bool:
	var forward := -global_basis.z
	var half_fov := deg_to_rad(fov * 0.5)
	var direction_to := global_transform.origin.direction_to(player.global_transform.origin)
	
	return forward.dot(direction_to) > cos(half_fov)


func _update_prediction_target() -> void:
	# calculate time to reach player
	var speed := max_speed if max_speed > 0.0 else 1.0
	var time_to_player := global_transform.origin.distance_to(player.global_transform.origin) / speed

	# clamp time to be no more then 1 second
	time_to_player = minf(time_to_player, movement_prediction_time)

	var target_prediction := player.global_transform.origin + player.average_velocity * time_to_player
	var dir_to_target := global_transform.origin.direction_to(target_prediction)
	var dir_to_player := global_transform.origin.direction_to(player.global_transform.origin)

	# is directions are to far apwart fall back to players current position
	if dir_to_player.dot(dir_to_target) < movement_prediction_threshold:
		target_prediction = player.global_transform.origin

	navigation_agent_3d.target_position = target_prediction


func _apply_friction(delta: float):
	var speed := velocity.length()
	if speed < 0.01:
		velocity = Vector3.ZERO
		return
	
	var control := maxf(speed, stop_speed)
	var drop := control * friction * delta
	var new_speed := maxf(0.0, speed - drop)
	if speed > 0.0:
		new_speed /= speed

	velocity *= new_speed


func _apply_accelerate(wish_dir: Vector3, wish_speed: float, delta: float):
	var current_speed := velocity.dot(wish_dir)
	var add_speed := max_speed - current_speed
	
	if add_speed <= 0.0:
		return
	
	var accel_speed := minf(acceleration * delta * wish_speed, add_speed)
	velocity += wish_dir * accel_speed