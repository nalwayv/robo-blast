class_name Player
extends CharacterBody3D


# NOTE's
# Kinematic Jump Formulas:
# link = https://www.gdquest.com/library/kinematic_jump_formulas/
# inital_velocity 	=  2 * height / time_to_peak
# jump_gavity 		= -2 * height / time_to_peak ^ 2
# fall_gravity 		= -2 * height / time_to_decent ^ 2
#
# Jump buffering:
# coyote time - forgives the player for being a few frames too late to to press jump
# jump buffer - forgive the player for being a few frame to early when pressing jump

enum JumpType {
	DEFAULT,
	KINEMATIC,
}

const SPEED := 5.0
const MOUSE_SENSITIVITY := 0.001

@export_category("jumping")
@export var jump_type := JumpType.KINEMATIC
@export var jump_height := 1.0 # default / kinematic
@export var jump_time_to_peak := 0.45 # kinematic
@export var jump_time_to_decent := 0.35 # kinematic
@export var fall_multiplier := 2.0 # default
@export var coyote_duration := 0.15
@export var jump_buffer_duration := 0.15

var mouse_motion := Vector2.ZERO
var was_on_floor := false

@onready var camera_rig: CameraRig = $CameraRig
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var damage_animation: AnimationPlayer = %DamageAnimation
@onready var game_over_menu: GameOverMenu = $GameOverMenu
@onready var jump_velocity := (2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity := (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity := (-2.0 * jump_height) / (jump_time_to_decent * jump_time_to_decent)
@onready var player_camera_origin := camera_rig.position


func _ready() -> void:
	add_to_group("health")
	add_to_group("ammo_handler")
	
	var health := get_node_or_null("%Health") as Health
	if health:
		health.died.connect(game_over_menu.game_over)
		health.damaged.connect(on_damage_taken)
		
	# capture mouse movement even when the cursor is outside the window.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			# get mouse motion
			mouse_motion = -event.relative * MOUSE_SENSITIVITY
			
			# apply lag when zommed in
			var weapon_zoom := get_node_or_null("WeaponZoom") as WeaponZoom
			if weapon_zoom and weapon_zoom.is_zoomed_in:
				mouse_motion *= weapon_zoom.fov_lag
				
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	update_camera_rotation()
	
	if not is_on_floor():
		apply_gravity(delta)
		
	# start coyote timer
	if was_on_floor and not is_on_floor():
		coyote_timer.start(coyote_duration)
		
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyote_timer.is_stopped():
			coyote_timer.stop()
			jump()
		else:
			jump_buffer_timer.start(jump_buffer_duration)
		
	# apply jump buffering
	if is_on_floor() and not jump_buffer_timer.is_stopped():
		jump_buffer_timer.stop()
		jump()
		
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
		
	# apply steay aim 
	var weapon_zoom := get_node_or_null("WeaponZoom") as WeaponZoom
	if weapon_zoom and weapon_zoom.is_zoomed_in:
		velocity.x *= weapon_zoom.steady_aim
		velocity.z *= weapon_zoom.steady_aim

	# apply bobbing
	camera_rig.add_bob(delta, velocity.length(), is_on_floor())
	
	was_on_floor = is_on_floor()
	
	move_and_slide()


func on_damage_taken() -> void:
	damage_animation.stop(false)
	damage_animation.play("take_damage")
	camera_rig.add_shake_rotation(deg_to_rad(25.0))


func get_kinematic_gravity() -> Vector3:
	return Vector3(0.0, fall_gravity if velocity.y < 0.0 else jump_gravity, 0.0)


## Rotate self using mouse motion
func update_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_rig.rotate_x(mouse_motion.y)
	camera_rig.rotation_degrees.x = clampf(camera_rig.rotation_degrees.x, -90.0, 90.0)
	
	# reset mouse to prevent the camera from continually rotating when the not moving.
	mouse_motion = Vector2.ZERO


## Apply gravity to velocity.
func apply_gravity(delta: float) -> void:
	match jump_type:
		JumpType.DEFAULT:
			if velocity.y >= 0.0:
				velocity += get_gravity() * delta
			else:
				velocity += get_gravity() * fall_multiplier * delta
		JumpType.KINEMATIC:
			velocity += get_kinematic_gravity() * delta


## Apply jump to current velocity.
func jump() -> void:
	match jump_type:
		JumpType.DEFAULT:
			velocity.y = sqrt(2.0 * jump_height * -get_gravity().y)
		JumpType.KINEMATIC:
			velocity.y = jump_velocity
