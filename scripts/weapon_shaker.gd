extends Node
@export var camera: CameraRig
@export var handler: WeaponHandler


func _ready() -> void:
	handler.weapon_switched.connect(add_shake)
	
	
func add_shake() -> void:
	camera.add_shake(1.0, 3.0)
