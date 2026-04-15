class_name Health
extends Node

## A component that manages the health of an entity.
## [br]It emits signals when the entity takes damage, dies, or when the health changes.

signal died
signal damaged
signal health_changed(amount: int)

@export var max_hitpoints := 100

var is_dead := false
var ratio: float:
	get:
		return float(hitpoints) / max_hitpoints
var hitpoints := max_hitpoints:
	get:
		return hitpoints
	set(value):
		value = mini(value, max_hitpoints)

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