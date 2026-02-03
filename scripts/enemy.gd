class_name Enemy
extends CharacterBody3D

const SPEED: float = 2.0

@export var attack_damage: int = 20
@export var fov: float = 90.0
@export var fov_range: float = 5.0
@export var aggro_range: float = 5.0

var provoked: bool = false
var attack_range: float = 2.0;

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player := get_tree().get_first_node_in_group("player") as Player


func _ready() -> void:
	add_to_group("health") # using groups like interfaces
	var health := get_node_or_null("%Health")
	if health:
		(health as Health).died.connect(queue_free)
		(health as Health).damaged.connect(func(): provoked = true)
	
	var debug := get_node_or_null("Debug")
	if debug:
		debug.fov = fov
		debug.fov_range = fov_range
		debug.aggro_range = aggro_range
		

func _process(_delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position


func _physics_process(delta: float) -> void:
	if not player:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	var next_path_position: Vector3 = navigation_agent_3d.get_next_path_position()
	var direction: Vector3 = global_position.direction_to(next_path_position)
	var distance: float = global_position.distance_to(player.global_position)
	
	if distance <= aggro_range and is_player_within_fov_dot():
		provoked = true
	
	if provoked and distance <= attack_range:
		animation_player.play("attack")
	
	if direction:
		#look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)
	
	if provoked:
		var target_yaw := atan2(-direction.x, -direction.z)
		var angle_diff := angle_difference(rotation.y, target_yaw)
		var turn_speed := 15.0 if absf(angle_diff) > deg_to_rad(60.0) else 5.0
		rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)
		
	move_and_slide()


#func look_at_target(target: Vector3) -> void:
	#var new_target := global_position + Vector3(target.x, 0, target.z)
	#look_at(new_target)


func attack() -> void:
	# NOTE - function is being called within attack animation on AnimationPlayer
	var health := player.get_node_or_null("%Health") as Health
	if health:
		health.hitpoints -= attack_damage


func is_player_within_fov_dot() -> bool:
	var forward := -global_basis.z
	var half_fov := deg_to_rad(fov * 0.5)
	var direction_to := global_position.direction_to(player.global_position)
	
	return forward.dot(direction_to) > cos(half_fov)
