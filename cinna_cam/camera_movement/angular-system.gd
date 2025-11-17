class_name AngularSystem extends Resource

@export var f := 4.0
@export var z := 1.8
@export var r := 0.8

var _velocity: float = 0.0
var _angle: float = 0.0

var float_small := 1e-6
var _top_angle_limit := 0.5 * PI - float_small
var _bottom_angle_limit := -0.5 * PI + float_small

func initialize(start_angle: float) -> void:
	_angle = start_angle
	_velocity = 0.0


func _compute_closed_form(
	current: float,
	velocity: float,
	target: float,
	delta: float
) -> Dictionary:

	var wn = 2.0 * PI * f
	var k1 = z / (PI * f)
	var k2 = 1.0 / (wn * wn)
	var k3 = r * z / wn

	# Because you always use target_velocity = 0.0
	var x = current - target
	var v = velocity

	var d := z

	if d < 1.0:
		# Underdamped (not your case, but keep complete)
		var wd = wn * sqrt(1.0 - d * d)

		var e = exp(-d * wn * delta)
		var c1 = x
		var c2 = (v + d * wn * x) / wd

		var new_x = e * (c1 * cos(wd * delta) + c2 * sin(wd * delta))
		var new_v = e * (
			-c1 * wn * d * cos(wd * delta)
			- c1 * wd * sin(wd * delta)
			+ c2 * wd * cos(wd * delta)
			- c2 * wn * d * sin(wd * delta)
		)

		return {
			"pos": target + new_x,
			"vel": new_v
		}

	else:
		# Overdamped or critically damped — your actual case (z = 1.8)
		var r1 = -wn * (d - sqrt(d * d - 1.0))
		var r2 = -wn * (d + sqrt(d * d - 1.0))

		var c2 = (v - r1 * x) / (r2 - r1)

		var c1 = x - c2

		var new_x = c1 * exp(r1 * delta) + c2 * exp(r2 * delta)
		var new_v = c1 * r1 * exp(r1 * delta) + c2 * r2 * exp(r2 * delta)

		return {
			"pos": target + new_x,
			"vel": new_v
		}


func get_next_angle(target_angle: float, delta: float) -> float:
	# Your wrap-around logic first
	if target_angle > 2.8 and _angle < -2.8:
			_angle += TAU
	elif target_angle < -2.8 and _angle > 2.8:
			_angle -= TAU

	var result = _compute_closed_form(_angle, _velocity, target_angle, delta)
	_angle = result.pos
	_velocity = result.vel

	return _angle


func get_next_constrained_angle(target_angle: float, delta: float) -> float:
	target_angle = clamp(target_angle, _bottom_angle_limit, _top_angle_limit)

	var result = _compute_closed_form(_angle, _velocity, target_angle, delta)
	_angle = clamp(result.pos, _bottom_angle_limit, _top_angle_limit)
	_velocity = result.vel

	return _angle