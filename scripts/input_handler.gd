class_name InputHandler
extends Node

signal shoot_pressed
signal shoot_released

#var input_motion := Vector2.ZERO
var input_direction := Vector2.ZERO
var is_jumping := false
var is_aiming := false
var is_foobar := false
var is_shooting := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_weapon"):
		is_shooting = true	
		shoot_pressed.emit()
		
	if event.is_action_released("fire_weapon"):
		is_shooting = false
		shoot_released.emit()


func _process(_delta: float) -> void:	
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	is_aiming = Input.is_action_pressed("aim")
	is_foobar= Input.is_action_just_pressed("foobar")
	
	if Input.is_action_pressed("jump"):
		is_jumping = true
