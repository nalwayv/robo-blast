class_name DampedSpring
extends Resource


const EPSILON := 0.0001

var frequency := 0.0
var damping := 0.0

var position := 0.0
var velocity := 0.0
var goal := 0.0

var _pp := 0.0
var _pv := 0.0
var _vp := 0.0
var _vv := 0.0


func step(delta: float) -> void:
	var zeta := maxf(damping, 0.0)
	var omega := maxf(frequency, 0.0)
	
	if omega < EPSILON:
		return
		
	if zeta > 1.0 + EPSILON:
		# Overdamped
		var za := -omega * zeta
		var zb := omega * sqrt(zeta * zeta - 1.0)
		var z1 := za - zb
		var z2 := za + zb
		
		var e1 := exp(z1 * delta)
		var e2 := exp(z2 * delta)
		
		var inv_2zb := 1.0 / (2.0 * zb)
		
		var e1_2zb := e1 * inv_2zb
		var e2_2zb := e2 * inv_2zb
		
		_pp = e1_2zb * z2 - z2 * e2_2zb + e2
		_pv = -e1_2zb + e2_2zb
		_vp = (z1 * e1_2zb - z2 * e2_2zb + e2) * z2
		_vv = -z1 * e1_2zb + z2 * e2_2zb
	elif zeta < 1.0 - EPSILON:
		# Underdamped
		var omega_zeta := omega * zeta
		var alpha := omega * sqrt(1.0 - zeta * zeta)
		
		var exp_term := exp(-omega_zeta * delta)
		var cos_term := cos(alpha * delta)
		var sin_term := sin(alpha * delta)
		
		var inv_alpha := 1.0 / alpha
		
		var exp_sin := exp_term * sin_term
		var exp_cos := exp_term * cos_term
		var exp_oz_sin_over_alpha := exp_term * omega_zeta * sin_term * inv_alpha
		
		_pp = exp_cos + exp_oz_sin_over_alpha
		_pv = exp_sin * inv_alpha
		_vp = -exp_sin * alpha - omega_zeta * exp_oz_sin_over_alpha
		_vv = exp_cos - exp_oz_sin_over_alpha
	else:
		# Critically damped
		var exp_term := exp(-omega * delta)
		var time_exp := delta * exp_term
		var time_exp_freq := time_exp * omega

		_pp = time_exp_freq + exp_term
		_pv = time_exp
		_vp = -omega * time_exp_freq
		_vv = -time_exp_freq + exp_term
		
	var rel_pos := position - goal
	var new_pos := rel_pos * _pp + velocity * _pv
	var new_vel := rel_pos * _vp + velocity * _vv
	
	position = new_pos + goal
	velocity = new_vel
