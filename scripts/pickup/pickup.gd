class_name Pickup
extends Area3D


@export_group("animation_spring")
@export var frequency := 3.0
@export var damping := 0.1
@export var nudge := 5.0
@export var time_interval := 1.0
@export var rotation_speed := 0.5

var time: float
var spring := DampedSpringV3.new()

@onready var ammo_mesh: MeshInstance3D = $AmmoMesh


func _ready() -> void:
	body_entered.connect(on_body_entered)
	
	spring.goal = position
	spring.position = spring.goal
	spring.frequency = frequency
	spring.damping = damping
	spring.velocity = Vector3(0.0, nudge, 0.0)


func _exit_tree() -> void:
	spring = null

func _process(delta: float) -> void:
	time += delta
	if time >= time_interval:
		time = 0.0
		spring.velocity += Vector3(0.0, nudge, 0.0)
		
	spring.step(delta)
	position = spring.position
	ammo_mesh.rotate_y(rotation_speed * delta)


func on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_collected(body)
		queue_free()


## override
func _collected(_body: Node3D) -> void:
	pass
