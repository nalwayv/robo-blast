class_name Pickup
extends Area3D

@export var use_spring_animation := true
@export_group("animation")
@export var input_curve: Curve
@export var frequency := 1.0
@export var amplitude := 0.4
@export_group("animation_spring")
@export var spring_frequency := 4.0
@export var spring_nudge := 0.8
@export_group("mesh rotation speed")
@export var rotation_speed := 1.5

var time := 0.0
# curve
var current_direction := 1
var origin_y := 0.0
#spring
var spring := DampedSpringV3.new()

@onready var mesh: MeshInstance3D = $Mesh


func _ready() -> void:
	body_entered.connect(on_body_entered)
	# curve
	origin_y = transform.origin.y
	# spring
	spring.goal = transform.origin
	spring.position = spring.goal
	spring.frequency = spring_frequency
	spring.damping = 0.0
	# because damping is 0 spring will never come to rest
	spring.velocity += Vector3(0.0, spring_nudge, 0.0)


func _process(delta: float) -> void:
	if use_spring_animation:
		spring.step(delta)
		transform.origin = spring.position
	else:
		time += delta * frequency * current_direction 
		if time > 1.0 or time < 0.0:
			current_direction = -current_direction
			time = clampf(time, 0.0, 1.0)

		transform.origin.y = origin_y + input_curve.sample(time) * amplitude

	mesh.rotate_y(rotation_speed * delta)


func on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_collected(body)
		queue_free()


## override
func _collected(_body: Node3D) -> void:
	pass
