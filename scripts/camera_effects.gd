class_name CameraEffects
extends Node

@export_category("camera")
@export var camera: Camera3D
@export_group("shake effect")
@export var position_frequency := 22.0
@export var position_damping := 0.5
@export var rotation_frequency := 22.0
@export var rotation_damping := 0.5
@export_group("bob effect")
@export var bob_frequency := 12.0
@export var bob_damping := 0.85
@export var bob_amplitude := 0.08

var pos_spring_x := DampedSpring.new()
var pos_spring_y := DampedSpring.new()
var pos_spring_z := DampedSpring.new()

var rot_spring_x := DampedSpring.new()
var rot_spring_y := DampedSpring.new()
var rot_spring_z := DampedSpring.new()

var bob_spring_x := DampedSpring.new()
var bob_spring_y := DampedSpring.new()
var bob_timer := 0.0

#@onready var origin := camera.global_transform


func _ready() -> void:
	for spring: DampedSpring in [pos_spring_x, pos_spring_y, pos_spring_z]:
		spring.frequency = position_frequency
		spring.damping = position_damping
		
	for spring: DampedSpring in [rot_spring_x, rot_spring_y, rot_spring_z]:
		spring.frequency = rotation_frequency
		spring.damping = rotation_damping
		
	for spring: DampedSpring in [bob_spring_x, bob_spring_y]:
		spring.frequency = bob_frequency
		spring.damping = bob_damping


func _process(delta: float) -> void:
	var t:= camera.transform
	
	# shake effect
	for spring in [pos_spring_x, pos_spring_y, pos_spring_z]:
		spring.step(delta)
	for spring in [rot_spring_x, rot_spring_y, rot_spring_z]:
		spring.step(delta)
		
	var pos_offset := Vector3(pos_spring_x.position, pos_spring_y.position, pos_spring_z.position)
	var rot_offset := Vector3(rot_spring_x.position, rot_spring_y.position, rot_spring_z.position)
	
	t.origin += t.basis * pos_offset
	t.basis *= Basis.from_euler(rot_offset)
	
	# bob effect
	for spring in [bob_spring_x, bob_spring_y]:
		spring.step(delta)
		
	var bob_offset := Vector3(bob_spring_x.position, bob_spring_y.position, 0.0)
	
	t.origin += t.basis * bob_offset
	
	camera.transform = t


func reset_shake() -> void:
	for p: DampedSpring in [pos_spring_x, pos_spring_y, pos_spring_z]:
		p.position = 0.0
		p.velocity = 0.0
	for r: DampedSpring in [rot_spring_x, rot_spring_y, rot_spring_z]:
		r.position = 0.0
		r.velocity = 0.0


## Add a shake effect to the camera
## [param strength] how strong the shake should be
## [param radians] how much the camera should rotate
func add_shake(strength: float, radians: float) -> void:
	pos_spring_x.velocity += randf_range(-strength, strength)
	pos_spring_y.velocity += randf_range(-strength, strength)

	#rot_spring_x.velocity += randf_range(-radians, radians)
	rot_spring_z.velocity += randf_range(-radians, radians)


## Add a shake rotation effect to the camera
## [param radians] how much the camera should rotate
func add_rotation_shake(radians: float) -> void:
#	rot_spring_x.velocity += rad * sign(angle)
#	rot_spring_z.velocity += radians
	rot_spring_x.velocity += randf_range(-radians, radians)
	rot_spring_z.velocity += randf_range(-radians, radians)


## Add a bobbing effect to the camera
## [param delta] time
## [param strength] how fast the camera bobbing should happen
## [param is_moving] whether to apply bobbing or not
func add_bob(delta: float, strength: float, is_moveing: bool) -> void:
	if is_moveing:
		bob_timer += delta
		var target_y := sin(bob_timer * strength * 2.0) * 0.05
		var target_x := cos(bob_timer * strength) * 0.03

#		bob_spring_y.velocity += target_y
#		bob_spring_x.velocity += target_x
		bob_spring_y.goal = target_y
		bob_spring_x.goal = target_x
	else:
		bob_spring_y.goal = 0.0
		bob_spring_x.goal = 0.0
#		bob_timer = lerpf(bob_timer, 0.0, delta * 0.6)
