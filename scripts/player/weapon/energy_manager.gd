class_name EnergyManager
extends Node

@export var max_energy := 10.0
@export var consumption_rate := 20.0
@export var regen_rate := 2.0
@export var recharge_delay := 0.5

@export_group("resource")
@export var ammo_bus: AmmoBus

var can_recharge: bool
var current_energy: float
var energy_ratio: float:
    get:
        var denom := 1.0 if max_energy <= 0 else max_energy
        return current_energy / denom

@onready var recharge_timer: Timer = $RechargeTimer


func _ready() -> void:
    recharge_timer.one_shot = true
    recharge_timer.wait_time = recharge_delay
    recharge_timer.timeout.connect(func() -> void: can_recharge = true)

    current_energy = max_energy


func consume_energy(delta: float) -> bool:
    if current_energy <= 0.0:
        recharge_timer.stop()
        can_recharge = false
        return false

    can_recharge = false
    recharge_timer.stop()

    current_energy = maxf(0.0, current_energy - consumption_rate * delta)

    ammo_bus.emit_energy_updated(energy_ratio)

    return true


func recharge_energy(delta: float) -> void:
    if can_recharge and current_energy < max_energy:
        current_energy = minf(max_energy, current_energy + regen_rate * delta)
        ammo_bus.emit_energy_updated(energy_ratio)


func start_recharge_timer() -> void:
    if recharge_timer.is_stopped() and not can_recharge:
        recharge_timer.start()