class_name InputHandler
extends Node

## A component that handles player input and emits signals for the player's actions.
## [br]**NOTE**: Inputs are currently for mouse and keyboard.

signal shoot_pressed
signal shoot_released
signal equip_pressed(index: int)
signal equip_next
signal equip_previous
signal jump_pressed
signal aim_pressed
signal aim_released

var direction: Vector2


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire_weapon"):
		shoot_pressed.emit()
	
	if event.is_action_released("fire_weapon"):
		shoot_released.emit()
	
	if event.is_action_pressed("equip_first"):
		equip_pressed.emit(0)
	
	if event.is_action_pressed("equip_second"):
		equip_pressed.emit(1)
	
	if event.is_action_pressed("equip_next"):
		equip_next.emit()
	
	if event.is_action_pressed("equip_previous"):
		equip_previous.emit()
	
	if event.is_action_pressed("jump"):
		jump_pressed.emit()

	if event.is_action_pressed("aim"):
		aim_pressed.emit()

	if event.is_action_released("aim"):
		aim_released.emit()


func _process(_delta: float) -> void:	
	direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
