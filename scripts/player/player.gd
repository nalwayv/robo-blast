class_name PlayerController
extends CharacterBody3D

const EDGE_FRICTION := 2.0

@export_group("movement")
@export var max_speed := 7.0
@export var stop_speed := 3.0
@export var acceleration := 10.0 
@export var friction := 6.0
@export var air_cap := 0.9
@export_subgroup("jumping")
@export var jump_height := 1.0
@export var jump_time_to_peak := 0.45
@export var jump_time_to_decent := 0.35
@export var air_acceleration := 100.0
@export_group("model movement")
@export var model_rotation_speed := 50.0
@export_group("timers")
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15
@export_group("componenets")
@export var health: Health
@export_group("resources")
@export var camera_shake_bus: CameraShakeBus
@export var shake_intensity:= 0.7

var jump_velocity := 0.0
var jump_gravity := 0.0
var fall_gravity := 0.0

var max_step_height := 0.25
var max_step_distance := 0.25

var max_historical_size: int
var historical_duration := 1.0
var historical_interval := 0.1
var historical_velocities: Array[Vector3] = []
var average_velocity: Vector3 :
	get:
		if historical_velocities.is_empty():
			return Vector3.ZERO

		var avg := Vector3.ZERO
		for vec: Vector3 in historical_velocities:
			avg += vec

		avg.y = 0.0
		
		avg /= historical_velocities.size()
		
		return avg

var coyote_timer := Timer.new()
var jump_buffer_timer := Timer.new()
var history_velocity_timer := Timer.new()

@onready var damage_animation: AnimationPlayer = $DamageAnimation
@onready var game_over_menu: GameOverMenu = $GameOverMenu
@onready var model: Node3D = $Model
@onready var near_edge_cast: RayCast3D = $NearEdgeCast


func _ready() -> void:
	# kinematic jump settings
	jump_velocity = (2.0 * jump_height) / jump_time_to_peak
	jump_gravity = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
	fall_gravity = (-2.0 * jump_height) / (jump_time_to_decent * jump_time_to_decent)
	
	# historical velocities
	max_historical_size = ceili(1.0 / historical_interval * historical_duration)
	historical_velocities.resize(max_historical_size)

	# timers
	coyote_timer.one_shot = true
	coyote_timer.wait_time = coyote_time
	add_child(coyote_timer)
	
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.wait_time = jump_buffer_time
	add_child(jump_buffer_timer)
	
	history_velocity_timer.one_shot = false
	history_velocity_timer.autostart = true
	history_velocity_timer.wait_time = historical_interval
	history_velocity_timer.timeout.connect(_on_update_historical_velocities)
	add_child(history_velocity_timer)

	# signals
	health.died.connect(game_over_menu.game_over)
	health.damaged.connect(_on_damage_taken)


func _process(delta: float) -> void:
	_update_model(delta)


func apply_gravity(delta) -> void:
	if is_on_floor():
		return

	var gavity_value := fall_gravity if velocity.y < 0.0 else jump_gravity
	velocity += Vector3(0.0, gavity_value, 0.0) * delta


func jump() -> void:
	velocity.y = jump_velocity


func apply_friction(delta: float):
	var speed := velocity.length()
	if speed < 0.01:
		velocity = Vector3.ZERO
		return
	
	var friction_amount := friction
	if _is_near_edge():
		friction_amount *= EDGE_FRICTION
	
	var control := maxf(speed, stop_speed)
	var new_speed := maxf(0.0, speed - control * friction_amount * delta)
	if speed > 0.0:
		new_speed /= speed
	velocity *= new_speed


func _is_near_edge() -> bool:
	if not is_on_floor():
		return false

	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	if horizontal_velocity.length() < 0.1:
		return false

	near_edge_cast.force_raycast_update()
	return not near_edge_cast.is_colliding()


func apply_accelerate(wish_dir: Vector3, wish_speed: float, delta: float):
	var current_speed := velocity.dot(wish_dir)
	var add_speed := max_speed - current_speed
	
	if add_speed <= 0.0:
		return
	
	var accel_speed := minf(acceleration * delta * wish_speed, add_speed)
	velocity += wish_dir * accel_speed


func apply_air_accelerate(wish_dir: Vector3, wish_speed: float, delta: float):
	var wish_speed_cap := minf(wish_speed, air_cap)
	var current_speed := velocity.dot(wish_dir)
	var add_speed := wish_speed_cap - current_speed

	if add_speed <= 0.0:
		return
	
	var accel_speed := minf(air_acceleration * wish_speed * delta, add_speed)
	velocity += wish_dir * accel_speed


func get_wish_velocity(input: Vector2) -> Vector3:
	return global_transform.basis * Vector3(input.x, 0.0, input.y)


func _test_body_motion(from: Transform3D, motion: Vector3, result: PhysicsTestMotionResult3D) -> bool:
	if not result:
		result = PhysicsTestMotionResult3D.new()

	var params := PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	params.max_collisions = 1
	return PhysicsServer3D.body_test_motion(get_rid(), params, result)


func try_to_step_over() -> void:
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	if is_zero_approx(horizontal_velocity.length()):
		return

	var movement_direction := horizontal_velocity.normalized()
	var distance := movement_direction * max_step_distance

	# forward probe
	var forward_result := PhysicsTestMotionResult3D.new()
	if not _test_body_motion(global_transform, distance, forward_result):
		return

	# slope
	var slope := forward_result.get_collision_normal().y
	if slope > 0.7:
		return

	# upward probe
	var upward_result := PhysicsTestMotionResult3D.new()
	var upward_travel_distance := max_step_height;
	if _test_body_motion( global_transform, Vector3(0, max_step_height, 0),upward_result):
		upward_travel_distance = upward_result.get_travel().y
		if is_zero_approx(upward_travel_distance):
			return

	# forward from raised probe
	var raised := global_transform.translated(Vector3(0, upward_travel_distance,0))
	var raised_forward_result := PhysicsTestMotionResult3D.new()
	if _test_body_motion(raised, distance, raised_forward_result):
		return

	# dornward from raised probe
	var raised_forward := raised.translated(distance)
	var down_result := PhysicsTestMotionResult3D.new()
	if not _test_body_motion(raised_forward, Vector3(0.0, -upward_travel_distance, 0), down_result):
		return

	var downward_travel_distance := down_result.get_travel().y
	var step := upward_travel_distance + downward_travel_distance
	if step <= 0.0 or step > max_step_height:
		return

	global_position.y += step
	velocity.y = maxf(0, velocity.y)


func _update_model(delta: float) -> void:
	var weight := clampf(model_rotation_speed * delta, 0.0, 1.0)
	model.global_transform = model.global_transform.interpolate_with(global_transform, weight)


func _on_damage_taken() -> void:
	damage_animation.stop()
	if damage_animation.has_animation("take_damage"):
		damage_animation.play("take_damage")
		
		if camera_shake_bus:
			camera_shake_bus.emit_shake(shake_intensity)


func _on_update_historical_velocities() -> void:
	if historical_velocities.size() == max_historical_size:
		historical_velocities.pop_front()

	historical_velocities.push_back(velocity)
