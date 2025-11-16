class_name AngularSystem extends Resource

@export var f := 4.0 # natural frequency (cycles/sec)
@export var z := 1.8 # damping ratio (>1 overdamped, =1 critical, <1 underdamped)
@export var r := 0.8 # response factor (>1 overshoots, =1 matches, <1 anticipates)

var _angle := 0.0
var _velocity := 0.0
var _prev_target := 0.0

var float_small: float = 1e-6
var _top_angle_limit: float = 0.5 * PI - float_small
var _bottom_angle_limit: float = -0.5 * PI + float_small

func initialize(start_angle: float) -> void:
	_angle = start_angle
	_prev_target = start_angle

func _solve_closed_form(x: float, v: float, target: float, dt: float) -> Array:
	var w_n := TAU * f
	var zeta := z
	var r_factor := r

	# effective stiffness input (target anticipation/overshoot)
	var x_input := target * r_factor

	var y0 := x - x_input
	var ydot0 := v

	var new_y := 0.0
	var new_ydot := 0.0

	if zeta < 1.0:
		# underdamped
		var w_d := w_n * sqrt(1.0 - zeta*zeta)
		var A := y0
		var B := (ydot0 + zeta * w_n * y0) / w_d
		var exp_term := exp(-zeta * w_n * dt)

		new_y = exp_term * (A * cos(w_d*dt) + B * sin(w_d*dt))
		new_ydot = exp_term * (
			- A * (zeta*w_n) * cos(w_d*dt)
			- A * w_d * sin(w_d*dt)
			- B * (zeta*w_n) * sin(w_d*dt)
			+ B * w_d * cos(w_d*dt)
		)
	elif zeta == 1.0:
		# critically damped
		var C1 := y0
		var C2 := ydot0 + w_n * y0
		var exp_term := exp(-w_n * dt)

		new_y = exp_term * (C1 + C2 * dt)
		new_ydot = exp_term * (C2 - w_n*(C1 + C2*dt))
	else:
		# overdamped
		var r1 := -w_n * (zeta - sqrt(zeta*zeta - 1.0))
		var r2 := -w_n * (zeta + sqrt(zeta*zeta - 1.0))

		var C2 := (ydot0 - r1*y0) / (r2 - r1)
		var C1 := y0 - C2

		new_y = C1 * exp(r1*dt) + C2 * exp(r2*dt)
		new_ydot = C1 * r1 * exp(r1*dt) + C2 * r2 * exp(r2*dt)

	var new_x := new_y + x_input
	return [new_x, new_ydot]


func get_next_angle(target_angle: float, delta: float) -> float:
	# wrap large jumps around ±π
	if target_angle > 2.8 and _angle < -2.8:
		_angle += TAU
	if target_angle < -2.8 and _angle > 2.8:
		_angle -= TAU

	var result := _solve_closed_form(_angle, _velocity, target_angle, delta)
	_angle = result[0]
	_velocity = result[1]

	return _angle


func get_next_constrained_angle(target_angle: float, delta: float) -> float:
	var clamped = clamp(target_angle, _bottom_angle_limit, _top_angle_limit)

	var result := _solve_closed_form(_angle, _velocity, clamped, delta)
	_angle = result[0]
	_velocity = result[1]

	# clamping again for safety
	return clamp(_angle, _bottom_angle_limit, _top_angle_limit)