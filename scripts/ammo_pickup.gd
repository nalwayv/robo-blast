extends Pickup

@export_category("ammo")
@export var ammo_amount: int = 0
@export var ammo_type: AmmoHandler.AmmoType


func _collected(body: Node3D) -> void:
	if body.has_meta("AmmoHandler"):
		var ammo_handler := body.get_meta("AmmoHandler") as AmmoHandler
		if ammo_handler:
			ammo_handler.add_ammo(ammo_type, ammo_amount)
