class_name CameraBobbing
extends CameraSpingComponent

@export var frequency := 12.0
@export var damping := 0.85

var bob_spring := DampedSpringV3.new()
var bob_timer := 0.0


func _ready() -> void:
	bob_spring.frequency = frequency
	bob_spring.damping = damping


func _process(delta: float) -> void:
	bob_spring.step(delta)


func _get_offset() -> Transform3D:
	return Transform3D(Basis(), bob_spring.position)


func apply_bob(delta: float, strength: float, is_moving: bool):
	if is_moving:
		bob_timer += delta
		bob_spring.goal = Vector3(
			cos(bob_timer * strength) * 0.03,
			sin(bob_timer * strength * 2.0) * 0.05,
			0.0,
		)
	else:
		bob_spring.goal = Vector3.ZERO
