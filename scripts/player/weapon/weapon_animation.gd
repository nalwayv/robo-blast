class_name WeaponAnimation
extends Node

const BUFFER := 0.99
const RECOIL_LENGTH_LIMIT := 0.2

@export var weapon_model: Node3D
@export var recoil_force := 0.1
@export var recoil_sharpness := 50.0
@export var recoil_rest := 10.0

var model_original_position: Vector3
var accumulate_recoil: Vector3


func _ready() -> void:
    model_original_position = weapon_model.position
    

func _process(delta: float) -> void:
    if weapon_model.position.z <= accumulate_recoil.z * BUFFER:
        weapon_model.position = weapon_model.position.lerp(accumulate_recoil, recoil_sharpness * delta)
    else:
        weapon_model.position = weapon_model.position.lerp(model_original_position, recoil_rest * delta)
        accumulate_recoil = weapon_model.position


func apply_recoil_animation() -> void:
    accumulate_recoil += Vector3.BACK * recoil_force
    accumulate_recoil = accumulate_recoil.limit_length(RECOIL_LENGTH_LIMIT)