class_name Airborn
extends State

@export_group("actor")
@export var player: PlayerControler
@export_group("components")
@export var input_handler: InputHandler


func _physics_update(_delta: float) -> void:
	if input_handler.is_jumping:
		if player.is_on_floor() or not player.coyote_timer.is_stopped():
			print("ctime end")
			player.coyote_timer.stop()
			player._jump()
		else:
			player.jump_buffer_timer.start(player.jump_buffer_time)
			
	input_handler.is_jumping = false
		
	if player.is_on_floor():
		if not player.jump_buffer_timer.is_stopped():
			player.jump_buffer_timer.stop()
			player._jump()
		else:
			transitioned.emit("move")
