class_name PlayerCamera
extends Camera3D


@export var rotation_speed := 45.0
@export_group("apply_smoothing")
@export var is_top_level := false
@export_group("impulse effect")
@export var impule_enabled := false
@export var frequency := 22.0
@export var damping := 0.5

var camera_impulse_spring := DampedSpringV3.new()

@onready var parent := get_parent()


func _ready() -> void:
	top_level = is_top_level

	camera_impulse_spring.frequency = frequency
	camera_impulse_spring.damping = damping


func _process(delta: float) -> void:
	var trans := Transform3D()
	
	if top_level and parent is Node3D:
		trans *= apply_smooth_movement(delta)
	
	if impule_enabled:
		camera_impulse_spring.step(delta)
		trans *= get_impule_offset()
	
	global_transform = trans

func apply_smooth_movement(delta) -> Transform3D:
	var weight := clampf(rotation_speed * delta, 0.0, 1.0)
	return global_transform.interpolate_with(parent.global_transform, weight)


func get_impule_offset() -> Transform3D:
	return Transform3D(Basis(), camera_impulse_spring.position)


func apply_impule(strength: float) -> void:
	var x := randf_range(-strength, strength)
	var y := randf_range(-strength, strength)
	camera_impulse_spring.velocity += Vector3(x, y, 0.0)
