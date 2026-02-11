class_name CameraShake
extends Node

@export var pos_frequency := 22.0
@export var pos_damping := 0.5

var pos_spring := DampedSpringV3.new()


func _ready() -> void:
	pos_spring.frequency = pos_frequency
	pos_spring.damping = pos_damping


func _process(delta: float) -> void:
	pos_spring.step(delta)


func get_offset() -> Transform3D:
	return Transform3D(Basis(), pos_spring.position)


func apply_impule(strength: float) -> void:
	var x := randf_range(-strength, strength)
	var y := randf_range(-strength, strength)
	pos_spring.velocity += Vector3(x, y, 0.0)
