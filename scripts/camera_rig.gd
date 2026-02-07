class_name CameraRig
extends Node3D

@export var rotation_speed := 45.0
@onready var camera: Camera3D = $Camera
@onready var camera_bob: CameraBobbing = $CameraBobbing
@onready var camera_shake: CameraShake = $CameraShake
@onready var camera_lean: CameraLean = $CameraLean


func _ready() -> void:
	camera.top_level = true


func _process(delta: float) -> void:
	# smooth camera
	var weight := clampf(delta * rotation_speed, 0.0, 1.0)
	var t := camera.global_transform.interpolate_with(global_transform, weight)
	
	# apply springs
	for child in get_children():
		if child is CameraSpingComponent:
			t *= child._get_offset()
	
	camera.global_transform = t


func apply_shake(strength: float, radians: float) -> void:
	camera_shake.apply_shake(strength, radians)


func apply_impulse(dir: Vector3, radians: float) -> void:
	camera_shake.apply_rotation_impulse(dir.normalized(), radians)


func apply_rotation_impulse(dir: Vector3, radians: float) -> void:
	camera_shake.apply_rotation_impulse(dir.normalized(), radians)


func apply_bob(delta: float, strength: float, is_moveing: bool) -> void:
	camera_bob.apply_bob(delta, strength, is_moveing)


## Add a lean when moveing along an axis
func apply_lean(axis: float) -> void:
	camera_lean.apply_lean(axis)
	
