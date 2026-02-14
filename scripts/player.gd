class_name PlayerControler
extends CharacterBody3D

# Kinematic Jump
# link = https://www.gdquest.com/library/kinematic_jump_formulas/

enum JumpType {
	DEFAULT,
	KINEMATIC,
}

@export_group("movement")
@export var movement_speed := 5.0
@export_group("jumping")
@export var jump_type := JumpType.KINEMATIC
@export_subgroup("kinematic")
@export var jump_height := 1.0
@export var jump_time_to_peak := 0.45
@export var jump_time_to_decent := 0.35
@export_subgroup("default")
@export var fall_multiplier := 2.0
@export_group("timers")
@export var coyote_time := 0.15 # allow jump when not on ground
@export var jump_buffer_time := 0.15 # allow jump when jump press befor hitting ground
@export_group("aiming")
@export_range(0.1, 1.0) var aim_standing_percent := 0.4
@export_range(0.1, 1.0) var aim_jumping_percent := 0.2
@export_group("componenets")
@export var mouse_capture: MouseCapture
@export var health: Health

var was_on_floor := false

var jump_velocity := 0.0
var jump_gravity := 0.0
var fall_gravity := 0.0

var coyote := 100.0
var coyote_timer := Timer.new()
var jump_buffer_timer := Timer.new()

@onready var damage_animation: AnimationPlayer = $DamageAnimation
@onready var player_model: MeshInstance3D = $PlayerModel
@onready var game_over_menu: GameOverMenu = $GameOverMenu


func _ready() -> void:
	# groups
	add_to_group("health")
	add_to_group("ammo_handler")
	
	# kinematic jump settings
	jump_velocity = (2.0 * jump_height) / jump_time_to_peak
	jump_gravity = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
	fall_gravity = (-2.0 * jump_height) / (jump_time_to_decent * jump_time_to_decent)
	
	# timers
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	
	jump_buffer_timer.one_shot = true
	add_child(jump_buffer_timer)
	
	# signals
	health.died.connect(game_over_menu.game_over)
	health.damaged.connect(_on_damage_taken)


func _process(_delta: float):
	rotate_y(mouse_capture.motion.x)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		_apply_gravity(delta)
			
	#if was_on_floor and not is_on_floor():
		#coyote_timer.start(coyote_time)
		#
	## NOTE: testing out a simple state machine
#
	was_on_floor = is_on_floor()
	move_and_slide()


func _on_damage_taken() -> void:
	damage_animation.stop()
	if damage_animation.has_animation("take_damage"):
		damage_animation.play("take_damage")


func _get_kinematic_gravity() -> Vector3:
	var gavity_value := fall_gravity if velocity.y < 0.0 else jump_gravity
	return Vector3(0.0, gavity_value, 0.0)


func _apply_gravity(delta: float) -> void:
	match jump_type:
		JumpType.DEFAULT:
			if velocity.y >= 0.0:
				velocity += get_gravity() * delta
			else:
				velocity += get_gravity() * fall_multiplier * delta
		JumpType.KINEMATIC:
			velocity += _get_kinematic_gravity() * delta


func _jump() -> void:
	match jump_type:
		JumpType.DEFAULT:
			velocity.y = sqrt(2.0 * jump_height * -get_gravity().y)
		JumpType.KINEMATIC:
			velocity.y = jump_velocity
