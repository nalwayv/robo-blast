class_name PlayerController
extends CharacterBody3D

# Kinematic Jump
# link = https://www.gdquest.com/library/kinematic_jump_formulas/


@export_group("movement")
@export var max_speed := 5.0
@export var stop_speed := 2.0
@export var acceleration := 10.0 
@export var friction := 6.0
@export var air_cap := 0.9
@export_subgroup("kinematic")
@export var jump_height := 1.0
@export var jump_time_to_peak := 0.45
@export var jump_time_to_decent := 0.35
@export var air_acceleration := 100.0
@export_group("jump timers")
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15
@export_group("aiming")
@export_range(0.1, 1.0) var aim_standing_percent := 0.4
@export_range(0.1, 1.0) var aim_jumping_percent := 0.2
@export_group("componenets")
@export var health: Health


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


func _on_damage_taken() -> void:
	damage_animation.stop()
	if damage_animation.has_animation("take_damage"):
		damage_animation.play("take_damage")


func apply_gravity(delta) -> void:
	if is_on_floor():
		return

	var gavity_value := fall_gravity if velocity.y < 0.0 else jump_gravity
	velocity += Vector3(0.0, gavity_value, 0.0) * delta


func on_jump() -> void:
	velocity.y = jump_velocity


func apply_friction(delta: float):
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
	
	if add_speed <= 0:
		return
	
	var accel_speed := minf(air_acceleration * wish_speed * delta, add_speed)
	velocity += wish_dir * accel_speed


func get_wish_velocity(input: Vector2) -> Vector3:
	return transform.basis * Vector3(input.x, 0.0, input.y)
