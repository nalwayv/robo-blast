class_name InputHandler
extends Node


signal shoot_pressed
signal shoot_released
#
signal equip_preessed(int)
signal equip_next
signal equip_previous

var direction := Vector2.ZERO
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

	if event.is_action_pressed("equip_first"):
		equip_preessed.emit(0)
		
	if event.is_action_pressed("equip_second"):
		equip_preessed.emit(1)
	
	if event.is_action_pressed("equip_next"):
		equip_next.emit()
		
	if event.is_action_pressed("equip_previous"):
		equip_previous.emit()

	if event.is_action_pressed("jump"):
		is_jumping = true


func _process(_delta: float) -> void:	
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	is_aiming = Input.is_action_pressed("aim")
	

func get_input_xz() -> Vector3:
	return Vector3(direction.x, 0.0, direction.y)