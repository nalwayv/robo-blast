class_name SmoothCamera
extends Node3D

@export var rotation_speed := 45.0

@onready var camera: Camera3D = $Camera


func _ready() -> void:
	camera.top_level = true


func _physics_process(delta: float) -> void:
	var weight := clampf(delta * rotation_speed, 0.0, 1.0)
	camera.global_transform = camera.global_transform.interpolate_with(global_transform, weight)
	camera.global_position = global_position
