class_name GameOverMenu
extends Control

@onready var restart: Button = %Restart
@onready var quit: Button = %Quit


func _ready() -> void:
	restart.pressed.connect(_on_restart_pressed)
	quit.pressed.connect(_on_quit_pressed)


## Displays the game over menu and pauses the game.
func game_over() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
