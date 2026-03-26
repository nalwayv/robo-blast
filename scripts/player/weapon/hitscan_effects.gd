class_name HitScanEffects
extends Node

@export var sparks: PackedScene
@export var muzzel_flash: GPUParticles3D


func add_hit_effect(spawn_global_pos: Vector3) -> void:
    var spark := sparks.instantiate() as GPUParticles3D
    if not spark:
        return
    
    get_tree().current_scene.add_child(spark)
    spark.global_position = spawn_global_pos


func restart_muzzel_flash() -> void:
    muzzel_flash.restart()