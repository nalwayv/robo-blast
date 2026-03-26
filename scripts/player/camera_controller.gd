class_name CameraController 
extends Node3D

const MIN_X_ROTATION := -89.0
const MAX_X_ROTATION := 70.0

@export_group("cameras")
@export var player_camera: Camera3D
@export var weapon_camera: Camera3D
@export_group("smoothing")
@export var smoothing_weight := 20.0
@export var base_sensitivity := 0.001
@export_group("sensitivity")
# How far you move mouse for a full 360 turn
@export var inches_per_360 := 12.0 
# Mouse hardware DPI
@export var dpi := 800.0 
@export var sensitivity := 1.0
@export_group("fov")
@export_range(0.1, 1.0) var fov_range_percent := 0.7
@export var transition_speed_in := 20.0
@export var transition_speed_out := 30.0

var main_default_fov := 0.0
var weapon_default_fov := 0.0

var target_rotation := Vector2.ZERO
var current_rotation := Vector2.ZERO
var radians_per_count := 0.0


func _ready() -> void:
	main_default_fov = player_camera.fov
	weapon_default_fov = weapon_camera.fov

	radians_per_count = TAU / (inches_per_360 * dpi * sensitivity)


func zoom_in(delta: float) -> void:
	player_camera.fov = lerpf(
		player_camera.fov,
		main_default_fov * fov_range_percent,
		transition_speed_in * delta)
	
	weapon_camera.fov = lerpf(
		weapon_camera.fov,
		weapon_default_fov * fov_range_percent,
		transition_speed_in * delta)


func zoom_out(delta: float) -> void:
	player_camera.fov = lerpf(
		player_camera.fov,
		main_default_fov,
		transition_speed_out * delta)
		
	weapon_camera.fov = lerpf(
		weapon_camera.fov,
		weapon_default_fov,
		transition_speed_out * delta)


func rotate_camera(mouse_motion: Vector2, delta: float) -> void:
	target_rotation += Vector2(mouse_motion.y, mouse_motion.x) * radians_per_count
	target_rotation.x = clampf(
		target_rotation.x,
		deg_to_rad(MIN_X_ROTATION), 
		deg_to_rad(MAX_X_ROTATION)
	)
	
	var weight := 1.0 - exp(-smoothing_weight * delta)
	current_rotation = current_rotation.lerp(target_rotation, weight)
	
	basis = Basis.from_euler(Vector3(current_rotation.x, 0.0, 0.0))


func get_horizontal_rotation() -> Basis:
	return Basis.from_euler(Vector3(0.0, current_rotation.y, 0.0))
