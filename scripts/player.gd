class_name Player
extends CharacterBody3D

enum JumpType {
	DEFAULT,
	KINEMATIC,
}

const SPEED: float = 5.0
const MOUSE_SENSITIVITY: float = 0.001
const PI_OVER_2: float = PI / 2.0

@export_category("jumping")
@export var jump_type: JumpType = JumpType.DEFAULT
@export var jump_height: float = 1.0 # default / kinematic
@export var jump_time_to_peak: float = 0.45 # kinematic
@export var jump_time_to_decent: float = 0.35 # kinematic
@export var fall_multiplier: float = 2.0 # default
@export var coyote_duration: float = 0.15
@export var jump_buffer_duration: float = 0.15
@export_category("health")
@export var max_hitpoints: int = 100

var mouse_motion := Vector2.ZERO
var hitpoints: int = max_hitpoints:
	set(value):
		# damage taken
		if value < hitpoints:
			damage_animation.stop(false)
			damage_animation.play("take_damage")
			
		hitpoints = value
		if hitpoints <= 0:
			game_over_menu.game_over()
			
var was_on_floor: bool
# Kinematic Jump Formulas
# https://www.gdquest.com/library/kinematic_jump_formulas/
# inital_velocity 	=  2 * height / time_to_peak
# jump_gavity 		= -2 * height / time_to_peak ^ 2
# fall_gravity 		= -2 * height / time_to_decent ^ 2
@onready var jump_velocity := (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity := (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity := (-2.0 * jump_height) / (jump_time_to_decent * jump_time_to_decent)
@onready var camera_pivot: Node3D = $CameraPivot
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var damage_animation: AnimationPlayer = %DamageAnimation
@onready var game_over_menu: GameOverMenu = $GameOverMenu


func _ready() -> void:
	# Capture mouse movement even when the cursor is outside the window.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * MOUSE_SENSITIVITY
			
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	_update_camera_rotation()
	
	# apply gravity
	if not is_on_floor():
		match jump_type:
			JumpType.DEFAULT:
				if velocity.y >= 0.0:
					velocity += get_gravity() * delta
				else:
					velocity += get_gravity() * fall_multiplier * delta
			JumpType.KINEMATIC:
				velocity += _get_kinematic_gravity() * delta
				
	# check if coyote time is available
	if was_on_floor and not is_on_floor():
		coyote_timer.start(coyote_duration)
		
	# handle jump and jump buffering
	# coyote time - forgives the player for being a few frames too late to to press jump
	# jump buffer - forgive the player for being a few frame to early when pressing jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyote_timer.is_stopped():
			coyote_timer.stop()
			_jump()
		else:
			jump_buffer_timer.start(jump_buffer_duration)
	
	if is_on_floor() and not jump_buffer_timer.is_stopped():
		jump_buffer_timer.stop()
		_jump()
				
	# handle movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
	
	was_on_floor = is_on_floor()
	move_and_slide()


func _get_kinematic_gravity() -> Vector3:
	return Vector3(0.0, fall_gravity if velocity.y < 0.0 else jump_gravity, 0.0)


## Rotate self using mouse motion
func _update_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90.0, 90.0)
	
	_reset_mouse_motion()


## Prevent camera from continually rotating when the mouse is not moving.
func _reset_mouse_motion() -> void:
	mouse_motion = Vector2.ZERO


func _jump() -> void:
	match jump_type:
		JumpType.DEFAULT:
			velocity.y = sqrt(2.0 * jump_height * -get_gravity().y)
		JumpType.KINEMATIC:
			velocity.y = jump_velocity
