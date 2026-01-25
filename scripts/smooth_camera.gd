class_name SmoothCamera
extends Node3D

@export var rotation_speed: float = 45.0

@onready var camera: Camera3D = $Camera


func _ready() -> void:
	# make sure its set
	camera.top_level = true


func _physics_process(delta: float) -> void:
	var weight := clampf(rotation_speed * delta, 0.0, 1.0)
	
	camera.global_transform = camera.global_transform.interpolate_with(global_transform, weight)
	camera.global_position = global_position
