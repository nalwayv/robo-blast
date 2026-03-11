class_name Item
extends Area3D

@export_group("animation")
@export var spring_frequency := 4.0
@export var spring_nudge := 0.8
@export var rotation_speed := 1.5

var time := 0.0
var spring := Vector3DampedSpring.new()

@onready var mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	spring.goal = position
	spring.position = spring.goal
	spring.frequency = spring_frequency
	spring.damping = 0.0

	spring.velocity += Vector3(0.0, spring_nudge, 0.0)

	body_entered.connect(on_body_entered)


func _process(delta: float) -> void:
	spring.step(delta)
	position = spring.position
	mesh.rotate_y(rotation_speed * delta)


func on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_collected(body)
		queue_free()


## override
func _collected(_body: Node3D) -> void:
	pass
