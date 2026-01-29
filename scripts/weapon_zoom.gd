class_name WeaponZoom
extends Node

@export var main_camera: Camera3D
@export var weapon_camera: Camera3D

var main_camera_fov: float
var weapon_camera_fov: float
var fov_multiplyer := 0.7
var fov_lag := 0.4
var transition_speed_in := 20.0
var transition_speed_out := 30.0
var steady_aim := 0.5
var is_zoomed_in := false


func _ready() -> void:
	if main_camera:
		main_camera_fov = main_camera.fov
	if weapon_camera:
		weapon_camera_fov = weapon_camera.fov


func _process(delta: float) -> void:
	if not main_camera or not weapon_camera:
		return
		
	if Input.is_action_pressed("aim"):
		is_zoomed_in = true
		main_camera.fov = lerpf(main_camera.fov, main_camera_fov * fov_multiplyer, delta * transition_speed_in)
		weapon_camera.fov = lerpf(weapon_camera.fov, weapon_camera_fov * fov_multiplyer, delta * transition_speed_in)
	else:
		is_zoomed_in = false
		main_camera.fov = lerpf(main_camera.fov, main_camera_fov, delta * transition_speed_out)
		weapon_camera.fov = lerpf(weapon_camera.fov, weapon_camera_fov, delta * transition_speed_out)
