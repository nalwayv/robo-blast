class_name EnemyController
extends CharacterBody3D


@export_group("movement")
@export var max_speed := 2.5
@export var stop_speed := 2.0
@export var acceleration := 10.0
@export var friction := 6.0
@export var min_turn_speed := 5.0
@export var max_turn_speed := 15.0
@export var smooth_direction := 10.0
@export_group("fov")
@export var detecion_radius := 5.0
@export var detection_angle_degrees := 90.0
@export_group("attack")
@export var attack_range := 2.0
@export var attack_damage := 20
@export_group("components")
@export var health: Health

var max_turn_angle := deg_to_rad(60.0)
var provoked := false
var movement_prediction_threshold := 0.33
var movement_prediction_time := 1.0
var current_direction := Vector3.FORWARD

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player := get_tree().get_first_node_in_group("player") as PlayerController


func _ready() -> void:
	add_to_group("enemy")
	
	health.died.connect(queue_free)
	health.damaged.connect(func() -> void: provoked = true)


func _process(_delta: float) -> void:
	_update_prediction_target()


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)

	if provoked:
		var next_path_position := navigation_agent_3d.get_next_path_position()
		var direction := global_position.direction_to(next_path_position)

		current_direction = current_direction.lerp(direction, smooth_direction * delta)
		var wish_direction := Vector3(current_direction.x, 0.0, current_direction.z).normalized()

		_apply_friction(delta)
		_apply_accelerate(wish_direction, max_speed, delta)
		_apply_rotation(direction, delta)
	else:
		_apply_friction(delta)

	move_and_slide()

	var distance := global_position.distance_to(player.global_position)
	_check_player_within_range(distance)
	_can_attack(distance)


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	velocity += get_gravity() * delta


func _apply_rotation(direction: Vector3, delta: float) -> void:
	var target_yaw := atan2(-direction.x, -direction.z)
	var angle_diff := angle_difference(rotation.y, target_yaw)
	var turn_speed := max_turn_speed if absf(angle_diff) > max_turn_angle else min_turn_speed
	rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)


## called from within animation player
func attack() -> void:
	var player_health := player.get_node_or_null("%Health") as Health
	if player_health:
		player_health.hitpoints -= attack_damage


func _check_player_within_range(distance: float) -> void:
	if distance <= detecion_radius and _is_player_within_fov_angle():
		provoked = true


func _can_attack(distance: float) -> void:
	if provoked and distance <= attack_range:
		animation_player.play("attack")


func _is_player_within_fov_angle() -> bool:
	var forward := -global_basis.z
	var half_fov := deg_to_rad(detection_angle_degrees * 0.5)
	var direction_to := global_position.direction_to(player.global_position)
	
	return forward.dot(direction_to) > cos(half_fov)


func _update_prediction_target() -> void:
	if not provoked:
		return

	# calculate time to reach player
	var time_to_player := minf(
		global_position.distance_to(player.global_position) / maxf(1.0, max_speed),
		1.0
	)

	var target_prediction := player.global_position + player.average_velocity * time_to_player
	var direction_to_target := global_position.direction_to(target_prediction)
	var direction_to_player := global_position.direction_to(player.global_position)

	# is directions are to far apwart fall back to players current position
	if direction_to_player.dot(direction_to_target) < movement_prediction_threshold:
		target_prediction = player.global_position

	navigation_agent_3d.target_position = target_prediction


func _apply_friction(delta: float) -> void:
	var speed := velocity.length()
	if is_zero_approx(speed):
		velocity = Vector3.ZERO
		return
	
	var control := maxf(speed, stop_speed)
	var drop := control * friction * delta
	var new_speed := maxf(0.0, speed - drop)
	if speed > 0.0:
		new_speed /= speed

	velocity *= new_speed


func _apply_accelerate(wish_dir: Vector3, wish_speed: float, delta: float) -> void:
	var current_speed := velocity.dot(wish_dir)
	var add_speed := max_speed - current_speed
	
	if add_speed <= 0.0:
		return
	
	var accel_speed := minf(acceleration * delta * wish_speed, add_speed)
	velocity += wish_dir * accel_speed