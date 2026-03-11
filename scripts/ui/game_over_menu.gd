class_name GameOverMenu
extends Control

@onready var restart: Button = %Restart
@onready var quit: Button = %Quit


func _ready() -> void:
	restart.pressed.connect(_on_restart)
	quit.pressed.connect(_on_quit)


func game_over() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit() -> void:
	get_tree().quit()
