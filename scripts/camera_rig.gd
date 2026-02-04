class_name CameraRig
extends Node3D


@export_category("camera")
@export var rotation_speed := 45.0
@export_group("shake effect")
@export var position_frequency := 22.0
@export var position_damping := 0.5
@export var rotation_frequency := 22.0
@export var rotation_damping := 0.5

var pos_spring_x := DampSpring.new()
var pos_spring_y := DampSpring.new()
var pos_spring_z := DampSpring.new()

var rot_spring_x := DampSpring.new()
var rot_spring_y := DampSpring.new()
var rot_spring_z := DampSpring.new()

@onready var camera: Camera3D = $Camera


func _ready() -> void:
	# for smooth rotation
	camera.top_level = true
	
	for spring: DampSpring in [pos_spring_x, pos_spring_y, pos_spring_z]:
		spring.frequency = position_frequency
		spring.damping = position_damping
		
	for spring: DampSpring in [rot_spring_x, rot_spring_y, rot_spring_z]:
		spring.frequency = rotation_frequency
		spring.damping = rotation_damping


func _process(delta: float) -> void:
	# smooth camera
	var weight := clampf(delta * rotation_speed, 0.0, 1.0)
	var t := camera.global_transform.interpolate_with(global_transform, weight)
	
	# shake
	for spring in [pos_spring_x, pos_spring_y, pos_spring_z]:
		spring.step(delta)
		
	for spring in [rot_spring_x, rot_spring_y, rot_spring_z]:
		spring.step(delta)
		
	var pos_offset := Vector3(pos_spring_x.position, pos_spring_y.position, pos_spring_z.position)
	var rot_offset := Vector3(rot_spring_x.position, rot_spring_y.position, rot_spring_z.position)
	
	# update transform
	t.origin += t.basis * pos_offset
	t.basis *= Basis.from_euler(rot_offset)
	
	camera.global_transform = t


func reset_shake() -> void:
	for p: DampSpring in [pos_spring_x, pos_spring_y, pos_spring_z]:
		p.position = 0.0
		p.velocity = 0.0
	for r: DampSpring in [rot_spring_x, rot_spring_y, rot_spring_z]:
		r.position = 0.0
		r.velocity = 0.0


## Testing out a simple camera shake effect that uses damped springs to rotate the camera
func add_shake(strength: float, radians: float) -> void:
	pos_spring_x.velocity += randf_range(-strength, strength)
	pos_spring_y.velocity += randf_range(-strength, strength)
	

	#rot_spring_x.velocity += randf_range(-rot, rot)
	rot_spring_z.velocity += randf_range(-radians, radians)


func add_shake_rotation(radians: float) -> void:
#	rot_spring_x.velocity += rad * sign(angle)
#	rot_spring_z.velocity += radians
	rot_spring_x.velocity += randf_range(-radians, radians)
	rot_spring_z.velocity += randf_range(-radians, radians)
