extends Pickup

@export_category("ammo")
@export var ammo_amount: int = 0
@export var ammo_type: AmmoHandler.AmmoType


func _collected(body: Node3D) -> void:
	if body.is_in_group("ammo_handler"):
		var ammo := body.get_node_or_null("%AmmoHandler") as AmmoHandler
		if ammo:
			ammo.add_ammo(ammo_type, ammo_amount)
