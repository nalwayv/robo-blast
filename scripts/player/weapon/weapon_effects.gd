class_name WeaponEffects
extends Node

@export var sparks_scene: PackedScene
@export var muzzel_particles: GPUParticles3D


func add_hit_effect(global_pos: Vector3) -> void:
	var spark := sparks_scene.instantiate() as GPUParticles3D
	if spark:
		get_tree().current_scene.add_child(spark)
		spark.global_position = global_pos


func emmit_muzzel_flash() -> void:
	muzzel_particles.restart()
