class_name Pickup
extends Area3D

@export_category("animation")
@export var frequency: float = 2.0
@export var amplitude: float = 0.5
@export var rotation_speed: float = 0.75

var time: float

@onready var original_position: Vector3 = position


func _ready() -> void:
	body_entered.connect(on_body_entered)


func _process(delta: float) -> void:
	time += delta
	position.y = amplitude * absf(sin(time * frequency)) + original_position.y
	rotate_y(rotation_speed * delta)


func on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_collected(body)
		queue_free()


## override
func _collected(_body: Node3D) -> void:
	pass
