class_name GroundMove
extends State


@export var player: PlayerController
@export_group("components")
@export var camera_controler: CameraController
@export var mouse_capture: MouseCapture
@export var input_handler: InputHandler


func _update(delta: float) -> void:
	camera_controler.update_camera_rotation(mouse_capture.motion)
	camera_controler.apply_fov(input_handler.is_aiming, delta)

	player.global_transform.basis = camera_controler.get_horizontal_rotation_basis()


func _physics_update(delta: float) -> void:
	var wish_vel := player.get_wish_velocity(input_handler.direction)
	var wish_dir := wish_vel.normalized()
	var wish_speed := wish_vel.length() * player.max_speed

	player.apply_friction(delta)
	player.apply_accelerate(wish_dir, wish_speed, delta)

	player.move_and_slide()

	if input_handler.is_jumping:
		player.on_jump()
		transitioned.emit("airborn")
		return
	
	if not player.is_on_floor():
		transitioned.emit("airborn")
