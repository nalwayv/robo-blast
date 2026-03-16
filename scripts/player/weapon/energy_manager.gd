class_name EnergyManager
extends Node

signal energy_updated

@export_group("energy")
@export var max_energy := 10.0
@export var consumption_rate := 20.0
@export var regen_rate := 2.0
@export var recharge_delay := 0.5

var can_regen := false

@onready var current_energy := max_energy
@onready var regen_timer: Timer = $RegenTimer


func _ready() -> void:
    regen_timer.one_shot = true
    regen_timer.wait_time = recharge_delay
    regen_timer.timeout.connect(func() -> void: can_regen = true)

    
func consume(delta: float) -> bool:
    if current_energy <= 0.0:
        regen_timer.stop()
        can_regen = false
        return false

    can_regen = false
    regen_timer.stop()

    current_energy = maxf(current_energy - consumption_rate * delta, 0.0)
    energy_updated.emit()

    return true


func regenerate(delta: float) -> void:
    if can_regen and current_energy < max_energy:
        current_energy = minf(current_energy + regen_rate * delta, max_energy)
        energy_updated.emit()


func get_ratio() -> float:
    var denom := 1.0 if max_energy <= 0 else max_energy
    return current_energy / denom


func begin_regen_timer() -> void:
    if regen_timer.is_stopped() and not can_regen:
        regen_timer.start()