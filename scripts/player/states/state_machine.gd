class_name StateMachine
extends Node


var current_state: State
var states: Dictionary[PlayerStates.Type, State] = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.transitioned.connect(_on_transition)
			states[child.state_type] = child
	
	states[PlayerStates.Type.GROUNDED]._enter()
	current_state = states[PlayerStates.Type.GROUNDED]


func _process(delta: float) -> void:
	if not current_state:
		return
		
	current_state._update(delta)


func _physics_process(delta: float) -> void:
	if not current_state:
		return
		
	current_state._physics_update(delta)


func _on_transition(state: PlayerStates.Type) -> void:
	var new_state := states.get(state) as State
	if not new_state or new_state == current_state:
		return
		
	current_state._exit()
	new_state._enter()
	current_state = new_state
