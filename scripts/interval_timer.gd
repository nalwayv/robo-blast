class_name IntervalTimer
extends Node

signal on_interval
signal finished

@export var interval: float = 0.2
@export var duration: float = 3.0
@onready var timer: Timer = $"Timer"

var elapsed: float = 0.0


func _ready():
	timer.one_shot = false
	timer.wait_time = interval
	timer.timeout.connect(_on_timeout)


func start_timer() -> void:
	elapsed = 0.0
	timer.start()


func _on_timeout() -> void:
	elapsed += interval
	on_interval.emit()

	if elapsed >= duration:
		timer.stop()
		finished.emit()
