@tool
extends Control

var line_start: float = 16
var line_end: float = 24


func _draw() -> void:
	# center circle
	# - background
	draw_circle(Vector2.ZERO, 4.0, Color.DIM_GRAY)
	# - forground
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
	
	# outer lines
	# - background
	draw_line(Vector2.UP * (line_start - 1), Vector2.UP * (line_end + 1), Color.DIM_GRAY, 4)
	draw_line(Vector2.LEFT * (line_start - 1), Vector2.LEFT * (line_end + 1), Color.DIM_GRAY, 4)
	draw_line(Vector2.DOWN * (line_start - 1), Vector2.DOWN * (line_end + 1), Color.DIM_GRAY, 4)
	draw_line(Vector2.RIGHT * (line_start - 1), Vector2.RIGHT * (line_end + 1), Color.DIM_GRAY, 4)
	# - forground
	draw_line(Vector2.UP * line_start, Vector2.UP * line_end, Color.WHITE, 2)
	draw_line(Vector2.LEFT * line_start, Vector2.LEFT * line_end, Color.WHITE, 2)
	draw_line(Vector2.DOWN * line_start, Vector2.DOWN * line_end, Color.WHITE, 2)
	draw_line(Vector2.RIGHT * line_start, Vector2.RIGHT * line_end, Color.WHITE, 2)
