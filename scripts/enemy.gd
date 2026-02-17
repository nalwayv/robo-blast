class_name EnemyControler
extends CharacterBody3D

const MAX_TURN_ANGLE := deg_to_rad(60.0)

@export var movement_speed := 2.0
@export var turn_speed_min := 5.0
@export var turn_speed_max := 15.0
@export var attack_damage := 20
@export var fov := 90.0
@export var fov_range := 5.0
@export var aggro_range := 5.0
@export var attack_range := 2.0
@export_group("components")
@export var health: Health
@export_group("debug")
@export var show_debug := false
@export var debug: Node3D

var provoked := false

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player := get_tree().get_first_node_in_group("player") as PlayerController


func _ready() -> void:
	add_to_group("health")
	
	health.died.connect(queue_free)
	health.damaged.connect(func(): provoked = true)
	
	if show_debug:
		debug.show_debug = true
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
	
	if distance <= aggro_range and _is_player_within_fov():
		provoked = true
	
	if provoked and distance <= attack_range:
		animation_player.play("attack")
	
	if direction:
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, movement_speed)
		velocity.z = move_toward(velocity.z, 0.0, movement_speed)
	
	if provoked:
		# rotate towards player
		var target_yaw := atan2(-direction.x, -direction.z)
		var angle_diff := angle_difference(rotation.y, target_yaw)
		var turn_speed := turn_speed_max if absf(angle_diff) > MAX_TURN_ANGLE else turn_speed_min
		rotation.y = lerp_angle(rotation.y, target_yaw, turn_speed * delta)
		
	move_and_slide()


func attack() -> void:
	# NOTE - this is being called within AnimationPlayer "attack"
	var player_health := player.get_node_or_null("%Health") as Health
	if player_health:
		player_health.hitpoints -= attack_damage


func _is_player_within_fov() -> bool:
	var forward := -global_basis.z
	var half_fov := deg_to_rad(fov * 0.5)
	var direction_to := global_position.direction_to(player.global_position)
	
	return forward.dot(direction_to) > cos(half_fov)
