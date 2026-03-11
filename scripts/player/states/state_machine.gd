class_name StateMachine
extends Node


var current_state: State
var states: Dictionary[PlayerStates.Type, State] = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			var state_type := _get_state_type_from_class(child)
			child.transitioned.connect(_on_transition)
			states[state_type] = child
	
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


func _get_state_type_from_class(state: State) -> PlayerStates.Type:
	match state.name:
		"Grounded": 
			return PlayerStates.Type.GROUNDED
		"Airborne": 
			return PlayerStates.Type.AIRBORNE
		_:
			printerr("Unknown state: ", state.name)
			return PlayerStates.Type.GROUNDED
