@tool
class_name EnemyDebug
extends Node3D

@export var show_debug := false
@export var fov_angle_degrees := 90.0
@export var detecion_radius := 10.0

var circumference_segments:= 64


func _process(_delta: float) -> void:
	if not show_debug:
		return

	draw_fov()
	# draw_detection_radius()
	# draw_transform()


# func draw_detection_radius() -> void:
# 	var prev := Vector3.ZERO
# 	for i in range(circumference_segments + 1):
# 		var t := lerpf(-TAU, TAU, float(i) / circumference_segments)
# 		var dir := -global_basis.z.rotated(Vector3.UP, t).normalized()
# 		var point := global_position + dir * detecion_radius
		
# 		if prev != Vector3.ZERO:
# 			DebugDraw3D.draw_line(prev, point, Color.GREEN)
# 		prev = point


# func draw_transform() -> void:
# 	var length := 2.0
# 	var offset := Vector3(0.0, 3.0, 0.0)
# 	var origin := global_position + offset

# 	var forward := -global_transform.basis.z
# 	var right := global_transform.basis.x
# 	var up := global_transform.basis.y

# 	DebugDraw3D.draw_arrow(origin, origin + forward * length, Color.BLUE, 0.1)
# 	DebugDraw3D.draw_arrow(origin, origin + right * length, Color.RED, 0.1)
# 	DebugDraw3D.draw_arrow(origin, origin + up * length, Color.GREEN, 0.1)


func draw_fov() -> void:
	var origin := global_position
	var forward := -global_basis.z
	var half_fov := deg_to_rad(fov_angle_degrees * 0.5)
	var left := forward.rotated(Vector3.UP, half_fov)
	var right := forward.rotated(Vector3.UP, -half_fov)
	var arc_segments := 16
	
	# draw bounds
	DebugDraw3D.draw_line(origin, origin + forward * detecion_radius, Color.GREEN)
	DebugDraw3D.draw_line(origin, origin + left * detecion_radius, Color.RED)
	DebugDraw3D.draw_line(origin, origin + right * detecion_radius, Color.RED)
	
	# draw arc
	var prev := Vector3.ZERO
	for i in range(arc_segments + 1):
		var weight := float(i) / arc_segments
		var angle := lerpf(-half_fov, half_fov, weight)
		var dir := forward.rotated(Vector3.UP, angle).normalized()
		var point := origin + dir * detecion_radius
		
		if prev != Vector3.ZERO:
			DebugDraw3D.draw_line(prev, point, Color.BLUE)
		prev = point
	
