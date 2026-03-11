class_name Vector3DampedSpring
extends RefCounted

## A utility class that simulates a damped spring for 3D vectors.
##
## Smoothly drives a [member position] toward a [member goal] over time,
## with configurable oscillation speed and damping behaviour. Useful for
## camera smoothing, procedural animation, and any value that should
## follow a target without snapping or oscillating forever.
##
## [b]Quick start:[/b]
## [codeblock]
## var spring := Vector3DampedSpring.new()
## spring.frequency = 10.0   # how fast it moves
## spring.damping   = 0.8    # 1.0 = no overshoot, <1.0 = bouncy
## spring.goal      = target_position
##
## func _process(delta):
##     spring.step(delta)
##     my_node.position = spring.position
## [/codeblock]
##
## Based on the derivation by Ryan Juckett:
## https://www.ryanjuckett.com/damped-springs/

const EPSILON := 0.0001

## Angular frequency (radians/s) controlling how fast the spring moves.
## Higher values produce a snappier, more responsive spring.
## Setting this to [code]0[/code] freezes the spring in place.
var frequency := 20.0: 
	set(value):
		frequency = value
		_last_delta = -1.0

## Damping ratio controlling how the spring decays toward the goal.
## [br][br]
## [b]> 1.0[/b] — Over-damped: slow approach with no oscillation.[br]
## [b]= 1.0[/b] — Critically damped: fastest settle with no overshoot.[br]
## [b]< 1.0[/b] — Under-damped: fast but bouncy, overshoots the goal.[br]
## [b]= 0.0[/b] — Undamped: oscillates forever.
var damping := 0.5: 
	set(value):
		damping = value
		_last_delta = -1.0

## Current position of the spring.
var position := Vector3.ZERO
## Current velocity of the spring.
var velocity := Vector3.ZERO
## Target position the spring is trying to reach.
var goal := Vector3.ZERO

var _pp := 1.0
var _pv := 0.0
var _vp := 0.0
var _vv := 1.0
var _last_delta := -1.0


## Advances the spring simulation by delta seconds.
func step(delta: float) -> void:
	if delta <= 0.0: 
		return
	
	if not is_equal_approx(delta, _last_delta):
		_update_coefficients(delta)
		_last_delta = delta

	var rel_pos := position - goal
	
	var new_pos := rel_pos * _pp + velocity * _pv
	var new_vel := rel_pos * _vp + velocity * _vv
	
	position = new_pos + goal
	velocity = new_vel


# Recomputes the four motion coefficients for the given timestep.
func _update_coefficients(delta: float) -> void:
	var zeta := maxf(damping, 0.0)
	var omega := maxf(frequency, 0.0)
	
	if omega < EPSILON:
		_pp = 1.0
		_pv = 0.0
		_vp = 0.0
		_vv = 1.0
		return

	if zeta > 1.0 + EPSILON:
		# Over-damped
		var za := -omega * zeta
		var zb := omega * sqrt(zeta * zeta - 1.0)
		var z1 := za - zb
		var z2 := za + zb
		var e1 := exp(z1 * delta)
		var e2 := exp(z2 * delta)
		var inv_2zb := 1.0 / (2.0 * zb)
		
		_pp = (e1 * z2 - e2 * z1) * inv_2zb
		_pv = (e2 - e1) * inv_2zb
		_vp = (e1 - e2) * (z1 * z2 * inv_2zb)
		_vv = (e2 * z2 - e1 * z1) * inv_2zb
	elif zeta < 1.0 - EPSILON:
		# Under-damped
		var omega_zeta := omega * zeta
		var alpha := omega * sqrt(1.0 - zeta * zeta)
		var exp_term := exp(-omega_zeta * delta)
		var cos_term := cos(alpha * delta)
		var sin_term := sin(alpha * delta)
		var inv_alpha := 1.0 / alpha
		
		_pp = exp_term * (cos_term + omega_zeta * sin_term * inv_alpha)
		_pv = exp_term * (sin_term * inv_alpha)
		_vp = -exp_term * (sin_term * alpha + omega_zeta * omega_zeta * sin_term * inv_alpha)
		_vv = exp_term * (cos_term - omega_zeta * sin_term * inv_alpha)
		
	else:
		# Critical-damped
		var exp_term := exp(-omega * delta)
		
		_pp = exp_term * (1.0 + omega * delta)
		_pv = exp_term * delta
		_vp = exp_term * (-omega * omega * delta)
		_vv = exp_term * (1.0 - omega * delta)
		
