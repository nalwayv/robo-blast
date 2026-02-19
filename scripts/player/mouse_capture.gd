class_name MouseCapture
extends Node


@export_range(1.0, 5.0) var mouse_sensitivity := 2.0

var motion := Vector2.ZERO


func _ready() -> void:
	mouse_sensitivity *= 0.001
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			motion.x += -event.relative.x * mouse_sensitivity
			motion.y += -event.relative.y * mouse_sensitivity
	
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(_delta: float) -> void:
	motion = Vector2.ZERO
