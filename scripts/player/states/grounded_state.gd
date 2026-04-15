class_name Grounded
extends PlayerBaseState

## A state representing the player being on the ground.


func _enter() -> void:
	input_handler.jump_pressed.connect(_on_jump_pressed)
	input_handler.aim_pressed.connect(_on_zoomed_in)
	input_handler.aim_released.connect(_on_zoomed_out)


func _exit() -> void:
	input_handler.jump_pressed.disconnect(_on_jump_pressed)
	input_handler.aim_pressed.disconnect(_on_zoomed_in)
	input_handler.aim_released.disconnect(_on_zoomed_out)


func _update(delta: float) -> void:
	camera_controller.rotate_camera(mouse_capture.motion, delta)
	
	if player.is_zoomed_in:
		camera_controller.zoom_in(delta)
	else:
		camera_controller.zoom_out(delta)

	player.global_basis = camera_controller.horizontal_rotation()


func _physics_update(delta: float) -> void:
	var input_direction := input_handler.direction
	var wish_direction := player.direction_to_world(input_direction)
	var wish_speed := input_direction.length() * player.max_speed

	player.apply_gravity(delta)
	player.apply_friction(delta)
	player.apply_accelerate(wish_direction, wish_speed, delta)

	player.try_step_up()

	player.move_and_slide()

	if not player.is_on_floor():
		transitioned.emit(PlayerStates.Type.AIRBORNE)


func _on_jump_pressed() -> void:
	player.jump()
	transitioned.emit(PlayerStates.Type.AIRBORNE)


func _on_zoomed_in() -> void: player.is_zoomed_in = true
func _on_zoomed_out() -> void: player.is_zoomed_in = false
