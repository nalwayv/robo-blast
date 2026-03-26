class_name HitScanAnimation
extends Node

const RECOIL_LENGTH_LIMIT := 0.2

@export_group("model")
@export var weapon_model: Node3D
@export_group("recoil")
@export var recoil_force := 0.1
@export var recoil_sharpness := 50.0
@export var recoil_rest_sharpness := 10.0

var weapon_model_original_position := Vector3.ZERO
var accumulate_recoil := Vector3.ZERO



func _ready() -> void:
    weapon_model_original_position = weapon_model.position
    
    # var parent := get_parent()
    # if parent and parent.has_signal("apply_animation_effects"):
    #     parent.apply_animation_effects.connect(_on_apply_animation_effects)


func _process(delta: float) -> void:
    if weapon_model.position.z <= accumulate_recoil.z * 0.99:
        weapon_model.position = weapon_model.position.lerp(accumulate_recoil, recoil_sharpness * delta)
    else:
        weapon_model.position = weapon_model.position.lerp(weapon_model_original_position, recoil_rest_sharpness * delta)
        accumulate_recoil = weapon_model.position


func apply_recoil_animation() -> void:
    accumulate_recoil += Vector3.BACK * recoil_force
    accumulate_recoil = accumulate_recoil.limit_length(RECOIL_LENGTH_LIMIT)