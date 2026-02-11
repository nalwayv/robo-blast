class_name CameraControler 
extends Node3D

const MIN_X_ROTATION := deg_to_rad(-89.0)
const MAX_X_ROTATION := deg_to_rad(70.0)

@export_group("cameras")
@export var player_camera: PlayerCamera
@export var weapon_camera: Camera3D
@export_group("fov")
@export_range(0.1, 1.0) var fov_range_percent := 0.7
@export var transition_speed_in := 20.0
@export var transition_speed_out := 30.0
@export_group("components")
@export var mouse_capture: MouseCapture
@export var input_handler: InputHandler

var main_default_fov := 0.0
var weapon_default_fov := 0.0


func _ready() -> void:
	main_default_fov = player_camera.fov
	weapon_default_fov = weapon_camera.fov


func _process(delta: float) -> void:
	rotate_camera(mouse_capture.motion)
	update_fov(delta)


func update_fov(delta: float) -> void:
	if input_handler.is_aiming:
		player_camera.fov = lerpf(
			player_camera.fov,
			main_default_fov * fov_range_percent,
			transition_speed_in * delta)
		weapon_camera.fov = lerpf(
			weapon_camera.fov,
			weapon_default_fov * fov_range_percent,
			transition_speed_in * delta)
	else:
		player_camera.fov = lerpf(
			player_camera.fov,
			main_default_fov,
			transition_speed_out * delta)
		weapon_camera.fov = lerpf(
			weapon_camera.fov,
			weapon_default_fov,
			transition_speed_out * delta)


func rotate_camera(move: Vector2) -> void:
	rotation.x = clampf(rotation.x + move.y, MIN_X_ROTATION, MAX_X_ROTATION)
