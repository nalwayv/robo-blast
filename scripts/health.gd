class_name Health
extends Node

signal died
signal damaged
signal health_changed(amount: int)

@export var max_hitpoints: int

var is_dead: bool
var hitpoints: int = max_hitpoints:
	get:
		return hitpoints
	set(value):
		if value < hitpoints:
			damaged.emit()
		
		hitpoints = value
		
		if not is_dead:
			health_changed.emit(hitpoints)
		
		if hitpoints <= 0:
			is_dead = true
			died.emit()


func _ready() -> void:
	hitpoints = max_hitpoints
