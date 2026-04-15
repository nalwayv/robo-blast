class_name Airborne
extends PlayerBaseState

## A state representing the player being in the air.

func _enter() -> void:
	player.coyote_timer.start()
	input_handler.jump_pressed.connect(_on_jump_pressed)

	input_handler.aim_pressed.connect(_on_zoomed_in)
	input_handler.aim_released.connect(_on_zoomed_out)


func _exit() -> void:
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()
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
	player.apply_air_accelerate(wish_direction, wish_speed, delta)
	
	player.move_and_slide()

	# jump buffering
	if player.is_on_floor() and not player.jump_buffer_timer.is_stopped():
		player.jump()
		player.jump_buffer_timer.stop()

	# ground transition
	if player.is_on_floor() and player.jump_buffer_timer.is_stopped():
		transitioned.emit(PlayerStates.Type.GROUNDED)


func _on_jump_pressed() -> void:
	if player.is_on_floor() or not player.coyote_timer.is_stopped():
		player.jump()
		player.coyote_timer.stop()
	else:
		player.jump_buffer_timer.start()

func _on_zoomed_in() -> void: player.is_zoomed_in = true
func _on_zoomed_out() -> void: player.is_zoomed_in = false
