class_name Grounded
extends PlayerBaseState


func _update(delta: float) -> void:
	camera_controller.rotate_camera(mouse_capture.motion, delta)
	
	if player.is_aiming:
		camera_controller.zoom_in(delta)
	else:
		camera_controller.zoom_out(delta)
	player.global_basis = camera_controller.horizontal_rotation()


func _physics_update(delta: float) -> void:
	player.apply_gravity(delta)

	player.update_movement_parameters()
	player.apply_friction(delta)
	player.apply_accelerate(delta)
	
	player.step_up()
	
	player.move_and_slide()

	player.step_down()

	player.was_on_floor = player.is_on_floor()

	_transition_to_airborn_from_jump()
	_transition_to_airborn()


func _transition_to_airborn_from_jump() -> void:
	if not player.is_jumping:
		return
	
	player.jump()
	transitioned.emit(PlayerStates.Type.AIRBORNE)


func _transition_to_airborn() -> void:
	if player.is_on_floor():
		return

	transitioned.emit(PlayerStates.Type.AIRBORNE)
	
