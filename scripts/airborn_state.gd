class_name Airborn
extends State


@export var player: PlayerController
@export_group("components")
@export var mouse_capture: MouseCapture
@export var input_handler: InputHandler
@export var camera_controler: CameraController


func _enter() -> void:
	player.coyote_timer.start(player.coyote_time)


func _exit() -> void:
	player.coyote_timer.stop()
	player.jump_buffer_timer.stop()


func _update(delta: float) -> void:
	camera_controler.update_camera_rotation(mouse_capture.motion)
	camera_controler.apply_fov(input_handler.is_aiming, delta)
	
	player.global_transform.basis = camera_controler.get_horizontal_rotation_basis()


func _physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	
	var wish_vel := player.get_wish_velocity(input_handler.direction)
	var wish_dir := wish_vel.normalized()
	var wish_speed := wish_vel.length()

	player.apply_air_accelerate(wish_dir, wish_speed, delta)


	if input_handler.is_jumping:
		if player.is_on_floor() or not player.coyote_timer.is_stopped():
			player.on_jump()
			player.coyote_timer.stop()
		else:
			player.jump_buffer_timer.start(player.jump_buffer_time)
	input_handler.is_jumping = false

	
	player.move_and_slide()


	if player.is_on_floor():
		if not player.jump_buffer_timer.is_stopped():
			player.on_jump()
			player.jump_buffer_timer.stop()
		else:
			transitioned.emit("move")