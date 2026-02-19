class_name StateMachine
extends Node


@export_group("states")
@export var inital_state := PlayerStates.Type.MOVING

var current_state: State
var states: Dictionary[PlayerStates.Type, State] = {}


func _ready() -> void:
	for child in get_children():
		if child is State:
			var state := _get_state_type_from_class(child)
			states[state] = child
			child.transitioned.connect(_on_transition)
	
	var starting_state := states.get(inital_state) as State
	if starting_state:
		starting_state._enter()
		current_state = starting_state


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
		"Moving": return PlayerStates.Type.MOVING
		"Airborne": return PlayerStates.Type.AIRBORNE
		_: return PlayerStates.Type.NONE
