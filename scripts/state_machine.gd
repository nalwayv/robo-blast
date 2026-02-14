class_name StateMachine
extends Node

@export_enum("move", "airborn") var inital_state := "move"
var current_state: State
var states: Dictionary[String, State] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
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


func _on_transition(state_name: String) -> void:
	var new_state := states.get(state_name) as State
	if not new_state or new_state == current_state:
		return
		
	current_state._exit()
	new_state._enter()
	current_state = new_state
