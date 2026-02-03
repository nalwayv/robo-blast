class_name PlayerCamera
extends Node3D

@export_category("camera")
@export var rotation_speed := 45.0

@export_group("shake")
@export var shake_frequency := 10.0
@export var shake_damping := 0.5
@export var shake_intensity := 1.0

var shake_spring_x := DampSpring.new()
var shake_spring_y := DampSpring.new()
var shake_spring_z := DampSpring.new()

@onready var camera: Camera3D = $Camera
@onready var base_local_position := camera.position


func _ready() -> void:
	camera.top_level = true
	
	for spring in [shake_spring_x, shake_spring_y, shake_spring_z]:
		spring.frequency = shake_frequency
		spring.damping = shake_damping


func _physics_process(delta: float) -> void:
	var weight := clampf(delta * rotation_speed, 0.0, 1.0)
	camera.global_transform = camera.global_transform.interpolate_with(global_transform, weight)
	camera.global_position = global_position
	
	# Apply shake rotation
	shake_spring_x.step(delta)
	shake_spring_y.step(delta)
	shake_spring_z.step(delta)
	
	camera.rotation.x += shake_spring_x.position
	camera.rotation.y += shake_spring_y.position
	camera.rotation.z += shake_spring_z.position


## Testing out a simple shake effect
func add_shake(intensity: float) -> void:
	var total_intensity := intensity * shake_intensity
	shake_spring_x.velocity += randf_range(-total_intensity, total_intensity)
	shake_spring_y.velocity += randf_range(-total_intensity, total_intensity)
	shake_spring_z.velocity += randf_range(-total_intensity, total_intensity)
