class_name CameraLean
extends CameraSpingComponent

@export var frequency := 22.0
@export var damping := 0.95
@export var lean_amount := 0.01

var lean := DampedSpringV3.new()


func _ready() -> void:
	lean.frequency = frequency
	lean.damping = damping
	
	
func _process(delta: float) -> void:
	lean.step(delta)


func _get_offset() -> Transform3D:
	return Transform3D(Basis.from_euler(lean.position), Vector3.ZERO)


func apply_lean(axis: float) -> void:
	lean.goal = Vector3(0.0, 0.0, axis * lean_amount)
