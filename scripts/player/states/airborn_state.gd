class_name Airborne
extends State

@export var player: PlayerController
@export_group("components")
@export var mouse_capture: MouseCapture
@export var input_handler: InputHandler
@export var camera_controller: CameraController


func _enter() -> void:
	player.coyote_timer.start()


func _exit() -> void:
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()


func _update(delta: float) -> void:
	camera_controller.rotate_camera(mouse_capture.get_motion(), delta)
	
	if input_handler.is_aiming:
		camera_controller.zoom_in(delta)
	else:
		camera_controller.zoom_out(delta)
	player.global_basis = camera_controller.get_horizontal_rotation()


func _physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	
	var wish_velocity := player.get_wish_velocity(input_handler.direction)
	var wish_direction := wish_velocity.normalized()
	var wish_speed := wish_velocity.length()

	player.apply_air_accelerate(wish_direction, wish_speed, delta)

	_handle_jump_input()

	player.move_and_slide()

	if player.is_on_floor():
		_handle_landing()


func _handle_jump_input() -> void:
	if not input_handler.is_jumping:
		return

	if player.is_on_floor() or not player.coyote_timer.is_stopped():
		player.jump()
		player.coyote_timer.stop()
		input_handler.is_jumping = false
	else:
		player.jump_buffer_timer.start()
		input_handler.is_jumping = false


func _handle_landing() -> void:
	if not player.jump_buffer_timer.is_stopped():
		player.jump()
		player.jump_buffer_timer.stop()
	else:
		transitioned.emit(PlayerStates.Type.GROUNDED)
