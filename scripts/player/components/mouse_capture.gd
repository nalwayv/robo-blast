class_name MouseCapture
extends Node

var _motion: Vector2
var motion: Vector2:
	get:
		var result := _motion
		_motion = Vector2.ZERO
		return result


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_motion += -event.relative
			
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
