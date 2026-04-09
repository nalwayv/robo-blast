class_name CameraController 
extends Node3D

const MIN_X_ROTATION := -89.0
const MAX_X_ROTATION := 70.0

@export_group("cameras")
@export var main_camera: Camera3D
@export var second_camera: Camera3D

@export_group("smoothing")
@export var smoothing_weight := 20.0
@export var base_sensitivity := 0.001

@export_group("sensitivity")
@export var inches_per_360 := 12.0 
@export var dpi := 800.0 
@export var sensitivity := 1.0

@export_group("field of view")
@export var zoom_in_ratio := 0.7
@export var transition_in_speed := 20.0
@export var transition_out_speed := 30.0

var main_camera_fov: float
var second_camera_fov: float
var target_rotation: Vector2
var current_rotation: Vector2
var radians_per_count: float


func _ready() -> void:
	main_camera_fov = main_camera.fov
	second_camera_fov = second_camera.fov

	radians_per_count = TAU / (inches_per_360 * dpi * sensitivity)


func zoom_in(delta: float) -> void:
	main_camera.fov = lerpf(
		main_camera.fov,
		main_camera_fov * zoom_in_ratio,
		transition_in_speed * delta)
	
	second_camera.fov = lerpf(
		second_camera.fov,
		second_camera_fov * zoom_in_ratio,
		transition_in_speed * delta)


func zoom_out(delta: float) -> void:
	main_camera.fov = lerpf(
		main_camera.fov,
		main_camera_fov,
		transition_out_speed * delta)
		
	second_camera.fov = lerpf(
		second_camera.fov,
		second_camera_fov,
		transition_out_speed * delta)


func rotate_camera(mouse_motion: Vector2, delta: float) -> void:
	target_rotation += Vector2(mouse_motion.y, mouse_motion.x) * radians_per_count
	target_rotation.x = clampf(
		target_rotation.x,
		deg_to_rad(MIN_X_ROTATION), 
		deg_to_rad(MAX_X_ROTATION)
	)
	
	var weight := 1.0 - exp(-smoothing_weight * delta)
	current_rotation = current_rotation.lerp(target_rotation, weight)
	basis = Basis.from_euler(Vector3.RIGHT * current_rotation.x)


func horizontal_rotation() -> Basis:
	return Basis.from_euler(Vector3.UP * current_rotation.y)
