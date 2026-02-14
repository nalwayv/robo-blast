class_name Move
extends State

@export_group("actor")
@export var player: PlayerControler
@export_group("components")
@export var input_handler: InputHandler


func _physics_update(_delta: float) -> void:
	if player.was_on_floor and not player.is_on_floor():
		print("ctime start")
		player.coyote_timer.start(player.coyote_time)
		
	# NOTE: testing out a simple state machine

	
	var input_v3 := Vector3(input_handler.input_direction.x, 0.0, input_handler.input_direction.y)
	var direction := (player.transform.basis * input_v3).normalized()
	
	var speed_this_frame := player.movement_speed
	if input_handler.is_aiming and player.is_on_floor():
		speed_this_frame *= player.aim_standing_percent
		
	if direction:
		player.velocity.x = direction.x * speed_this_frame
		player.velocity.z = direction.z * speed_this_frame
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, speed_this_frame)
		player.velocity.z = move_toward(player.velocity.z, 0.0, speed_this_frame)
	
	
	if input_handler.is_jumping:
		transitioned.emit("airborn")
