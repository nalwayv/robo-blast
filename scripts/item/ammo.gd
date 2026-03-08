class_name Ammo
extends Item

@export_category("ammo")
@export var ammo_amount := 0
@export var ammo_type: AmmoType.Type


func _collected(body: Node3D) -> void:
	var ammo := body.get_node_or_null("%AmmoHandler") as AmmoHandler
	if ammo:
		ammo.add_ammo(ammo_type, ammo_amount)
