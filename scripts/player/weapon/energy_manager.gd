class_name EnergyManager
extends Node

@export_group("energy")
@export var max_energy := 10.0
@export var consumption_rate := 20.0
@export var regen_rate := 2.0
@export var recharge_delay := 0.5
@export_group("bus")
@export var ammo_bus: AmmoBus

var can_regen := false
var ratio: float:
    get:
        var denom := 1.0 if max_energy <= 0 else max_energy
        return current_energy / denom

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

    ammo_bus.emit_energy_updated(ratio)

    return true


func regenerate(delta: float) -> void:
    if can_regen and current_energy < max_energy:
        current_energy = minf(current_energy + regen_rate * delta, max_energy)

        ammo_bus.emit_energy_updated(ratio)


func begin_regen_timer() -> void:
    if regen_timer.is_stopped() and not can_regen:
        regen_timer.start()