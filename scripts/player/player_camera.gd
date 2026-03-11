class_name PlayerCamera
extends Camera3D

@export var rotation_speed := 50.0
@export_group("impulse effect")
@export var frequency := 22.0
@export var damping := 0.5
@export_group("resources")
@export var camera_shake_bus: CameraShakeBus

var camera_impulse_spring := Vector3DampedSpring.new()

@onready var parent := get_parent()


func _ready() -> void:
	top_level = true

	camera_impulse_spring.frequency = maxf(20.0, frequency)
	camera_impulse_spring.damping = maxf(0.5, damping)

	camera_shake_bus.shake_request.connect(_on_shake_request)


func _process(delta: float) -> void:
	var transform3D := Transform3D()
	
	if parent is Node3D:
		transform3D *= _smooth_movement(delta)
	
	camera_impulse_spring.step(delta)
	transform3D *= _get_shake_offset()
	
	global_transform = transform3D


func _smooth_movement(delta: float) -> Transform3D:
	var weight := clampf(rotation_speed * delta, 0.0, 1.0)
	return global_transform.interpolate_with(parent.global_transform, weight)


func _get_shake_offset() -> Transform3D:
	return Transform3D(Basis(), camera_impulse_spring.position)


func _on_shake_request(intensity: float) -> void:
	var x := randf_range(-intensity, intensity)
	var y := randf_range(-intensity, intensity)

	camera_impulse_spring.velocity += Vector3(x, y, 0.0)