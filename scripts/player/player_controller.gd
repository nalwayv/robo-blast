class_name PlayerController
extends CharacterBody3D

const MAX_HISTORICAL_VELCITIES := 10
const HISTORICAL_TIMER_INTERVAL := 0.1
const MAX_EDGE_FRICTION := 2.0
const MAX_STEP_HEIGHT := 2.0
const MAX_STEP_DISTANCE := 0.25

@export_group("movement")
@export var max_speed := 7.0
@export var stop_speed := 3.0
@export var acceleration := 10.0 
@export var friction := 6.0
@export var air_cap := 0.9
@export_group("jumping")
@export var max_jump_height := 1.0
@export var jump_time_to_peak := 0.45
@export var jump_time_to_decent := 0.35
@export var air_acceleration := 100.0
@export_group("timers")
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15
@export_group("resources")
@export var camera_bus: CameraBus
@export_subgroup("camera shake")
@export var shake_intensity:= 0.7
@export_group("misc")
@export var model_rotation_speed := 50.0

# kinematic jump.
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

# Record average velocity over time.
var historical_velocities: Array[Vector3] = []
var average_velocity: Vector3:
	get:
		if historical_velocities.is_empty():
			return Vector3.ZERO

		var avg := Vector3.ZERO
		for vec: Vector3 in historical_velocities:
			avg += vec
		avg.y = 0.0
		
		return avg / historical_velocities.size()

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var history_velocity_timer: Timer = $HistoricalVelocityTimer
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var game_over_menu: GameOverMenu = $GameOverMenu
@onready var model: Node3D = $Model
@onready var edge_raycast: RayCast3D = $NearEdgeCast
@onready var health: Health = $Health

func _ready() -> void:
	add_to_group("player")

	# kinematic jump settings
	jump_velocity = 2.0 * max_jump_height / jump_time_to_peak
	jump_gravity = -2.0 * max_jump_height / pow(jump_time_to_peak, 2.0)
	fall_gravity = -2.0 * max_jump_height / pow(jump_time_to_decent, 2.0)
	
	# historical velocities
	historical_velocities.resize(MAX_HISTORICAL_VELCITIES)

	# timers
	coyote_timer.one_shot = true
	coyote_timer.wait_time = coyote_time
	
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.wait_time = jump_buffer_time
	
	history_velocity_timer.one_shot = false
	history_velocity_timer.autostart = true
	history_velocity_timer.wait_time = HISTORICAL_TIMER_INTERVAL
	history_velocity_timer.timeout.connect(_on_update_historical_velocities)

	# signals
	health.died.connect(game_over_menu.game_over)
	health.damaged.connect(_on_damage_taken)


func _process(delta: float) -> void:
	_update_model(delta)


func apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	var gravity := fall_gravity if velocity.y < 0.0 else jump_gravity
	velocity += Vector3.UP * gravity * delta


func jump() -> void:
	velocity.y = jump_velocity


func apply_friction(delta: float) -> void:
	var speed := velocity.length()
	if speed < 0.01:
		velocity = Vector3.ZERO
		return
	
	var friction_amount := friction
	if _is_near_edge():
		friction_amount *= MAX_EDGE_FRICTION
	
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

	edge_raycast.force_raycast_update()
	return not edge_raycast.is_colliding()


func apply_accelerate(wish_dir: Vector3, wish_speed: float, delta: float) -> void:
	var current_speed := velocity.dot(wish_dir)
	var add_speed := max_speed - current_speed
	
	if add_speed <= 0.0:
		return
	
	var accel_speed := minf(acceleration * delta * wish_speed, add_speed)
	velocity += wish_dir * accel_speed


func apply_air_accelerate(wish_dir: Vector3, wish_speed: float, delta: float) -> void:
	var wish_speed_cap := minf(wish_speed, air_cap)
	var current_speed := velocity.dot(wish_dir)
	var add_speed := wish_speed_cap - current_speed

	if add_speed <= 0.0:
		return
		
	var accel_speed := minf(air_acceleration * wish_speed * delta, add_speed)
	velocity += wish_dir * accel_speed


func direction_to_world(input_direction: Vector2) -> Vector3:
	return global_basis * Vector3(input_direction.x, 0.0, input_direction.y)


func _test_body_motion(from: Transform3D, motion: Vector3, result: PhysicsTestMotionResult3D) -> bool:
	if not result:
		result = PhysicsTestMotionResult3D.new()

	var params := PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	params.max_collisions = 1
	return PhysicsServer3D.body_test_motion(get_rid(), params, result)


## check if the player model can step over objects of a determined hight and how to react.
func try_to_step_over() -> void:
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	if is_zero_approx(horizontal_velocity.length()):
		return

	var direction := horizontal_velocity.normalized()
	var distance := direction * MAX_STEP_DISTANCE
	var elevation_change := MAX_STEP_HEIGHT

	# forward probe
	var test_forward := PhysicsTestMotionResult3D.new()
	if not _test_body_motion(global_transform, distance, test_forward):
		return

	# ground normal is sloped, so we can't step up
	if test_forward.get_collision_normal().y > 0.7:
		return

	# check if we can step up
	var test_upwards := PhysicsTestMotionResult3D.new()
	if _test_body_motion( global_transform, Vector3.UP * MAX_STEP_HEIGHT, test_upwards):
		elevation_change = test_upwards.get_travel().y
		if is_zero_approx(elevation_change):
			return

	# check forward from the raised position
	var raised := global_transform.translated(Vector3.UP * elevation_change)
	var test_forward_raised := PhysicsTestMotionResult3D.new()
	if _test_body_motion(raised, distance, test_forward_raised):
		return

	# check down from the raised position
	var raised_forward := raised.translated(distance)
	var test_down_from_forward_raised := PhysicsTestMotionResult3D.new()
	if not _test_body_motion(raised_forward, Vector3.DOWN * elevation_change, test_down_from_forward_raised):
		return

	var deceleration_change := test_down_from_forward_raised.get_travel().y
	var total_elevation := elevation_change + deceleration_change
	if total_elevation <= 0.0 or total_elevation > MAX_STEP_HEIGHT:
		return

	global_position.y += total_elevation
	velocity.y = 0.0


func _update_model(delta: float) -> void:
	var weight := clampf(model_rotation_speed * delta, 0.0, 1.0)
	model.global_transform = model.global_transform.interpolate_with(global_transform, weight)


func _on_damage_taken() -> void:
	animation.stop()
	
	if animation.has_animation("take_damage"):
		animation.play("take_damage")
		
		if camera_bus:
			camera_bus.emit_shake(shake_intensity)


func _on_update_historical_velocities() -> void:
	if historical_velocities.size() == MAX_HISTORICAL_VELCITIES:
		historical_velocities.pop_front()

	historical_velocities.push_back(velocity)
