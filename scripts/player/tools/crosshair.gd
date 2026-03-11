@tool
class_name Crosshair
extends Control

var line_start := 16.0
var line_end := 24.0
var background_radius := 4.0
var forground_radius := 3.0
var background_width := 5.0

var forground_width := 4.0
var directions := [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
]
var background_color := Color.DIM_GRAY
var forground_color := Color.WHITE


func _draw() -> void:
	_draw_center_circle()
	_draw_crosshair()


func _draw_center_circle() -> void:
	draw_circle(Vector2.ZERO, background_radius, background_color)
	draw_circle(Vector2.ZERO, forground_radius, forground_color)


func _draw_crosshair() -> void:
	for dir: Vector2 in directions:
		draw_line(
			dir * (line_start - 1.0),
			dir * (line_end + 1.0),
			background_color,
			background_width
		)
		draw_line(
			dir * line_start,
			dir * line_end,
			forground_color,
			forground_width
		)