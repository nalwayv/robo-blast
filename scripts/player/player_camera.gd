class_name PlayerCamera
extends Camera3D

@export var rotation_speed := 50.0
@export_group("apply_smoothing")
@export var is_top_level := false
@export_group("impulse effect")
@export var impule_enabled := false
@export var frequency := 22.0
@export var damping := 0.5
@export_group("resources")
@export var camera_shake_bus: CameraShakeBus

var camera_impulse_spring := DampedSpringV3.new()

@onready var parent := get_parent()


func _ready() -> void:
	# camera
	top_level = is_top_level

	# spring
	camera_impulse_spring.frequency = frequency
	camera_impulse_spring.damping = damping

	# bus
	if camera_shake_bus:
		camera_shake_bus.shake_request.connect(_on_shake_request)


func _exit_tree() -> void:
	camera_impulse_spring = null


func _process(delta: float) -> void:
	var t := Transform3D()
	
	if top_level and parent is Node3D:
		t *= _apply_smooth_movement(delta)
	
	if impule_enabled:
		camera_impulse_spring.step(delta)
		t *= _get_shake_offset()
	
	global_transform = t


func _apply_smooth_movement(delta) -> Transform3D:
	# because the camera is top_level we need to use global to find were the parent is
	# and follow it
	var weight := clampf(rotation_speed * delta, 0.0, 1.0)
	return global_transform.interpolate_with(parent.global_transform, weight)


func _get_shake_offset() -> Transform3D:
	return Transform3D(Basis(), camera_impulse_spring.position)

# # TODO: 
# func apply_shake(strength: float) -> void:
# 	var x := randf_range(-strength, strength)
# 	var y := randf_range(-strength, strength)
# 	camera_impulse_spring.velocity += Vector3(x, y, 0.0)


func _on_shake_request(intensity: float) -> void:
	var x := randf_range(-intensity, intensity)
	var y := randf_range(-intensity, intensity)

	camera_impulse_spring.velocity += Vector3(x, y, 0.0)