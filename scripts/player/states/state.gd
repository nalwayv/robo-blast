class_name State
extends Node

@export var state_type: PlayerStates.Type

@warning_ignore("unused_signal")
signal transitioned(state: PlayerStates.Type)


func _enter() -> void: pass
func _exit() -> void: pass
func _update(_delta: float) -> void: pass
func _physics_update(_delta: float) -> void: pass
