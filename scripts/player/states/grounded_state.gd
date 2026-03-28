class_name Grounded
extends PlayerBaseState


func _update(delta: float) -> void:
	camera_controller.rotate_camera(mouse_capture.get_motion(), delta)
	
	if input_handler.is_aiming:
		camera_controller.zoom_in(delta)
	else:
		camera_controller.zoom_out(delta)
	player.global_basis = camera_controller.get_horizontal_rotation()


func _physics_update(delta: float) -> void:
	var wish_velocity := player.get_wish_velocity(input_handler.direction)
	var wish_direction := wish_velocity.normalized()
	var wish_speed := wish_velocity.length() * player.max_speed

	player.apply_friction(delta)
	player.apply_accelerate(wish_direction, wish_speed, delta)
	player.try_to_step_over()
	
	player.move_and_slide()

	_transition_to_airborn_from_jump()
	_transition_to_airborn()


func _transition_to_airborn_from_jump() -> void:
	if not input_handler.is_jumping:
		return
	
	player.jump()
	transitioned.emit(PlayerStates.Type.AIRBORNE)


func _transition_to_airborn() -> void:
	if player.is_on_floor():
		return

	transitioned.emit(PlayerStates.Type.AIRBORNE)
	
