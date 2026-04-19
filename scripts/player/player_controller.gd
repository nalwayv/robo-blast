class_name PlayerController
extends CharacterBody3D

## The main player controller that handles movement and jumping similar to a standard first person controller, 
## but with some extra features like coyote time, jump buffering and step up.
## [br]**NOTE**: Step up is not perfect and is just a simple implementation that uses gdots physics test motion 
## to check if the player can step up.

const MAX_HISTORICAL_VELCITIES := 10
const HISTORICAL_TIMER_INTERVAL := 0.1
const MAX_EDGE_FRICTION := 2.0

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

var step_height := 0.3
var step_check_distance := 0.2

var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

var is_zoomed_in: bool

# Record average velocity over time
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
@onready var direction_pivot: Node3D = $DirectionPivot

func _ready() -> void:
	add_to_group("player")

	# kinematic jump settings
	jump_velocity = 2.0 * max_jump_height / jump_time_to_peak
	jump_gravity = -2.0 * max_jump_height / (jump_time_to_peak * jump_time_to_peak)
	fall_gravity = -2.0 * max_jump_height / (jump_time_to_decent * jump_time_to_decent)
	
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

	# just a simple way to see current horizontal direction of the player for debugging
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length_squared() > 0.01:
		var local_dir := (global_basis.inverse() * horizontal_velocity).normalized()
		direction_pivot.rotation.y = atan2(-local_dir.x, -local_dir.z)


## Applies gravity to the player
func apply_gravity(delta: float) -> void:
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
		return

	var gravity := fall_gravity if velocity.y < 0.0 else jump_gravity
	velocity += Vector3.UP * gravity * delta


## Applies an instant vertical velocity to the player to make it jump.
func jump() -> void:
	velocity.y = jump_velocity


## Applies friction to the player when grounded. if near an edge friction is increased 
## to prevent the player from sliding off the edge.
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

	# NOTE:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length_squared() < 0.01:
		return false

	edge_raycast.force_raycast_update()
	return not edge_raycast.is_colliding()


## Applies acceleration to the player when grounded based on players wish direction.
func apply_accelerate(wish_direction: Vector3, wish_speed: float, delta: float) -> void:
	var current_speed := velocity.dot(wish_direction)
	var add_speed := max_speed - current_speed
	
	if add_speed <= 0.0:
		return
	
	var accel_speed := minf(acceleration * delta * wish_speed, add_speed)
	velocity += wish_direction * accel_speed


## Applies acceleration to the player when airborn based on players wish direction.
func apply_air_accelerate(wish_direction: Vector3, wish_speed: float, delta: float) -> void:
	var wish_speed_cap := minf(wish_speed, air_cap)
	var current_speed := velocity.dot(wish_direction)
	var add_speed := wish_speed_cap - current_speed

	if add_speed <= 0.0:
		return
		
	var accel_speed := minf(air_acceleration * wish_speed * delta, add_speed)
	velocity += wish_direction * accel_speed


## Converts a 2D input direction to a 3D world direction based on the players current orientation
func direction_to_world(input_direction: Vector2) -> Vector3:
	return global_basis * Vector3(input_direction.x, 0.0, input_direction.y)


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


## A step mechanic that tries to step up small obstacles using godots physics test motion.
## The step currently has a predefined height and distance that it checks for,
## to prevent the player from stepping up too high or too far.
func try_step_up() -> void:
	var horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	#NOTE: squared < 0.1 | length_squared < (0.1 * 0.1)
	if horizontal_velocity.length_squared() < 0.01:
		return

	var direction := horizontal_velocity.normalized()
	var params := PhysicsTestMotionParameters3D.new()
	var result := PhysicsTestMotionResult3D.new()

	# check forward if nothing is blocking return
	params.from = global_transform
	params.motion = direction * step_check_distance
	if not PhysicsServer3D.body_test_motion(get_rid(), params, result):
		return

	# check height is clear
	var raised := global_transform.translated(Vector3.UP * step_height)
	params.from = raised
	params.motion = direction * step_check_distance
	if PhysicsServer3D.body_test_motion(get_rid(), params, result):
		return

	# check down if there is something to land on
	params.from = raised.translated(direction * step_check_distance)
	params.motion = Vector3.DOWN * step_height
	if not PhysicsServer3D.body_test_motion(get_rid(), params, result):
		return

	# step up
	var step_amount := step_height - result.get_travel().length()
	if step_amount > 0.01:
		global_position.y += step_amount
		global_position += direction * 0.05
