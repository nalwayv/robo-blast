class_name EnemyController
extends CharacterBody3D

## A controller for the enemy.
## The enemy has a simple AI that allows it to navigate towards the player, 
## attack, and react to being damaged.

const MAX_TURN_ANGLE := 60.0
const PREDICTION_THRESHOLD := 0.33
const NAVIGATION_INTERVAL := 0.1

@export_group("movement")
@export var max_speed := 2.5
@export var stop_speed := 2.0
@export var acceleration := 10.0
@export var friction := 6.0
@export var min_turn_speed := 5.0
@export var max_turn_speed := 15.0
@export var smooth_direction := 10.0

@export_group("field of view")
@export var detection_angle := 90.0

@export_group("attack")
@export var attack_range := 2.0
@export var attack_damage := 20

@export_group("components")
@export var health: Health

var player: PlayerController

var provoked: bool
var navigation_delay: float
var player_within_range: bool
var current_direction := Vector3.FORWARD

var hit_tween: Tween
var base_color: Color

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var detection_area: Area3D = $DetectionArea
@onready var mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	add_to_group("enemy")
	
	player = get_tree().get_first_node_in_group("player") as PlayerController

	health.died.connect(queue_free)
	health.damaged.connect(_on_damaged)

	detection_area.body_entered.connect(_on_area_entered)
	detection_area.body_exited.connect(_on_area_exited)

	# hit flash but the material needs to be duplicated 
	# to prevent other instances from also flashing
	if mesh.material_override:
		mesh.material_override = (mesh.material_override.duplicate() as Material)
		base_color = mesh.material_override.albedo_color


func _process(delta: float) -> void:
	navigation_delay -= delta
	if navigation_delay <= 0:
		navigation_agent_3d.target_position = _update_prediction_target()
		navigation_delay = NAVIGATION_INTERVAL


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)

	if provoked:
		if not navigation_agent_3d.is_navigation_finished():
			var next_path_position := navigation_agent_3d.get_next_path_position()
			var direction := global_position.direction_to(next_path_position)
			current_direction = current_direction.lerp(direction, smooth_direction * delta)

			var wish_direction := Vector3(current_direction.x, 0.0, current_direction.z).normalized()
			var wish_speed := max_speed

			_apply_friction(delta)
			_apply_accelerate(wish_direction, wish_speed, delta)
			_apply_rotation(wish_direction, delta)
		else:
			# just look at player
			var direction := global_position.direction_to(player.global_position)
			current_direction = current_direction.lerp(direction, smooth_direction * delta)
			var wish_direction := Vector3(current_direction.x, 0.0, current_direction.z).normalized()

			_apply_rotation(wish_direction, delta)
			_apply_friction(delta)

	else:
		_apply_friction(delta)

	move_and_slide()

	_check_player_within_proximity()
	_can_perform_attack()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	velocity += get_gravity() * delta


func _apply_rotation(direction: Vector3, delta: float) -> void:
	var target_yaw := atan2(-direction.x, -direction.z)
	var angle_diff := angle_difference(rotation.y, target_yaw)
	var turn_speed := max_turn_speed if absf(angle_diff) > deg_to_rad(MAX_TURN_ANGLE) else min_turn_speed
	rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)


func _check_player_within_proximity() -> void:
	if provoked or not player_within_range:
		return

	if not _is_player_within_fov_angle():
		return

	provoked = true


func _is_player_within_fov_angle() -> bool:
	var forward := -global_basis.z
	var half_fov := deg_to_rad(detection_angle * 0.5)
	var direction_to := global_position.direction_to(player.global_position)
	
	return forward.dot(direction_to) > cos(half_fov)


func _can_perform_attack() -> void:
	if not provoked:
		return 
		
	if global_position.distance_to(player.global_position) > attack_range:
		return

	animation_player.play("attack")


func _update_prediction_target() -> Vector3:
	if not provoked:
		return Vector3.ZERO

	# calculate time to reach player based on current distance and max speed
	var distance_to_player := global_position.distance_to(player.global_position)
	var time_to_player := minf(distance_to_player / maxf(1.0, max_speed), 1.0)

	# predict player position based on their current velocity
	var target_prediction := player.global_position + player.average_velocity * time_to_player
	var direction_to_target := global_position.direction_to(target_prediction)
	var direction_to_player := global_position.direction_to(player.global_position)

	# if the predicted position is significantly off from the player's current position, use the player's current position instead
	if direction_to_player.dot(direction_to_target) < PREDICTION_THRESHOLD:
		target_prediction = player.global_position

	return target_prediction


func _apply_friction(delta: float) -> void:
	var speed := velocity.length()
	if speed < 0.1:
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


func _on_damaged() -> void:
	if not provoked:
		provoked = true

	var mat := mesh.material_override
	if not mat:
		return

	if hit_tween and hit_tween.is_running():
		hit_tween.kill()
	
	# simple hit flash
	hit_tween = create_tween()
	hit_tween.tween_property(mat, "albedo_color", Color.WHITE, 0.05)
	hit_tween.tween_property(mat, "albedo_color", base_color, 0.1)


# region [Animation Func Tracks]

func attack() -> void:
	# called from within animation player
	var player_health := player.get_node_or_null("Health") as Health
	if player_health:
		player_health.hitpoints -= attack_damage

# endregion


# region [Detection Area]

func _on_area_entered(body: Node3D) -> void:
	if not body.is_in_group("player") or provoked:
		return

	player_within_range = true


func _on_area_exited(body: Node3D) -> void:
	if not body.is_in_group("player") or provoked:
		return

	player_within_range = false

# endregion
