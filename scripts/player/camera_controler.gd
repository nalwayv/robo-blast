class_name CameraController 
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

var main_default_fov := 0.0
var weapon_default_fov := 0.0
var _rotation := Vector3.ZERO


func _ready() -> void:
	main_default_fov = player_camera.fov
	weapon_default_fov = weapon_camera.fov


func apply_fov(zoom_in: bool, delta: float) -> void:
	if zoom_in:
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


func update_camera_rotation(input: Vector2) -> void:
	_rotation.x += input.y # up, down
	_rotation.y += input.x # left, right
	_rotation.z = 0.0

	_rotation.x = clampf(_rotation.x, MIN_X_ROTATION, MAX_X_ROTATION)
	var camera_rotation := Vector3(_rotation.x, 0.0, 0.0)
	
	transform.basis = Basis.from_euler(camera_rotation)


func get_rotation_basis() -> Basis:
	return Basis.from_euler(_rotation)


func get_horizontal_rotation_basis() -> Basis:
	return Basis.from_euler(Vector3(0.0, _rotation.y, 0.0))
