@tool
extends Node3D

var fov: float = 90.0
var fov_range: float = 10.0
var aggro_range: float = 10.0
var circumference_segments: int = 64


func _process(_delta: float) -> void:
	if owner is Enemy:
		fov = owner.fov
		fov_range = owner.fov_range
		aggro_range = owner.aggro_range
	
	draw_fov()
	draw_aggro_range()


func draw_aggro_range() -> void:
	var prev := Vector3.ZERO
	for i in range(circumference_segments + 1):
		var t := lerpf(-TAU, TAU, float(i) / circumference_segments)
		var dir := -global_basis.z.rotated(Vector3.UP, t).normalized()
		var point := global_position + dir * aggro_range
		
		if prev != Vector3.ZERO:
			DebugDraw3D.draw_line(prev, point, Color.GREEN)
		prev = point


func draw_fov() -> void:
	var origin := global_position
	var forward := -global_basis.z
	var half_fov := deg_to_rad(fov * 0.5)
	var left := forward.rotated(Vector3.UP, half_fov)
	var right := forward.rotated(Vector3.UP, -half_fov)
	var arc_segments := 16
	
	# draw bounds
	DebugDraw3D.draw_line(origin, origin + forward * fov_range, Color.GREEN)
	DebugDraw3D.draw_line(origin, origin + left * fov_range, Color.RED)
	DebugDraw3D.draw_line(origin, origin + right * fov_range, Color.RED)
	
	# draw arc
	var prev := Vector3.ZERO
	for i in range(arc_segments + 1):
		var t := lerpf(-half_fov, half_fov, float(i) / arc_segments)
		var dir := forward.rotated(Vector3.UP, t).normalized()
		var point := origin + dir * fov_range
		
		if prev != Vector3.ZERO:
			DebugDraw3D.draw_line(prev, point, Color.BLUE)
		prev = point
	
