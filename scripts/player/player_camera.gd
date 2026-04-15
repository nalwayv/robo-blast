class_name PlayerCamera
extends Camera3D

## A Helper node that handles the players camera movement and shake effects.
## camera bus is used to receive shake requests from the player controller and 
## apply them to the camera using a damped spring for smooth movement.

@export_group("camera smoothing")
@export var rotation_speed := 50.0

@export_group("camera shake")
@export var frequency := 22.0
@export var damping := 0.5

@export_group("resources")
@export var camera_bus: CameraBus

var camera_impulse_spring := DampedSpring.new()


func _ready() -> void:
	top_level = true

	camera_impulse_spring.frequency = frequency
	camera_impulse_spring.damping = damping

	camera_bus.shake_request.connect(_on_camera_shake)


func _process(delta: float) -> void:
	var transform3D := Transform3D()
	
	camera_impulse_spring.step(delta)
	
	transform3D *= _smooth_camera_movement(delta)
	transform3D *= _camera_shake_offset()
	
	global_transform = transform3D


func _smooth_camera_movement(delta: float) -> Transform3D:
	if get_parent() is Node3D:
		var parent := get_parent() as Node3D
		var weight := clampf(rotation_speed * delta, 0.0, 1.0)
		return global_transform.interpolate_with(parent.global_transform, weight)

	return Transform3D.IDENTITY


func _camera_shake_offset() -> Transform3D:
	return Transform3D(Basis.IDENTITY, camera_impulse_spring.position)


func _on_camera_shake(intensity: float) -> void:
	var x := randf_range(-intensity, intensity)
	var y := randf_range(-intensity, intensity)

	camera_impulse_spring.velocity += Vector3(x, y, 0.0)
