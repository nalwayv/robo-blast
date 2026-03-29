class_name WeaponDamage
extends Node


@export var damage_amount := 1


func apply_damage_to_target(target: Node3D) -> void:
    var health := target.get_node_or_null("Health") as Health
    if health:
        health.hitpoints -= damage_amount