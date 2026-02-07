class_name CameraShake
extends CameraSpingComponent

const PITCH_LIMIT := deg_to_rad(15.0)

@export_category("shake")
@export_group("position")
@export var pos_frequency := 22.0
@export var pos_damping := 0.5
@export_group("rotation")
@export var rot_frequency := 22.0
@export var rot_damping := 0.5

var pos_spring := DampedSpringV3.new()
var rot_spring := DampedSpringV3.new()


func _ready() -> void:
	pos_spring.frequency = pos_frequency
	pos_spring.damping = pos_damping
	rot_spring.frequency = rot_frequency
	rot_spring.damping = rot_damping


func _process(delta: float) -> void:
	pos_spring.step(delta)
	rot_spring.step(delta)


func _get_offset() -> Transform3D:
	return Transform3D(Basis.from_euler(rot_spring.position), pos_spring.position)


func apply_shake(strength: float, radians: float) -> void:
	pos_spring.velocity += Vector3(
		randf_range(-strength, strength),
		randf_range(-strength, strength),
		0.0,
	)
		
	rot_spring.velocity += Vector3(
		randf_range(-radians, radians),
		0.0,
		randf_range(-radians, radians),
	)
	
	
func apply_impulse(direction: Vector3, strength: float) -> void:
	pos_spring.velocity += direction.normalized() * strength


func apply_rotation_impulse(axis: Vector3, radians: float) -> void:
	rot_spring.velocity += axis.normalized() * radians
