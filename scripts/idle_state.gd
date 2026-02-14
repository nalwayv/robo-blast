class_name IdleState
extends State

@export var input_handler: InputHandler
@export var player: PlayerControler

func _enter() -> void: 
	print("enter idle")
	
	
func _physics_update(_delta: float) -> void: 
	var dir := input_handler.input_direction
	if dir:
		transitioned.emit("moving")
		
	if player.is_on_floor() and input_handler.is_jumping:
		transitioned.emit("airborn")
