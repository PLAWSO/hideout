@tool
class_name PathSection extends Path3D

enum TrackingType { FOLLOW, STATIONARY, ANGLE }

@export_group("Speed")
@export var speed: float = -1.0
@export var time_to_finish: float = 1.0

@export_group("Tracking")
@export var tracking_type: TrackingType = TrackingType.FOLLOW:
	set(value):
		tracking_type = value
		notify_property_list_changed() # tells the inspector to rebuild

# FOLLOW TrackingType
var follow_target: Node3D = null
var follow_target_node: NodePath = NodePath()

# ANGLE TrackingType
var angle_target: Vector2
var relative_to_travel_direction: bool = true
var angle_target_degrees_x: float = 0.0:
	set(value):
		angle_target_degrees_x = value
		angle_target.x = deg_to_rad(value)

var angle_target_degrees_y: float = 0.0:
	set(value):
		angle_target_degrees_y = value
		angle_target.y = deg_to_rad(value)

var zero_length: bool = false
var length: float = 0.0
var target: PathFollow3D = PathFollow3D.new()

func _get_property_list():
	var props = []

	match tracking_type:
		TrackingType.FOLLOW:
			props.append({
				name = "Follow Target",
				type = TYPE_NIL,
				hint_string = "follow_target_",
				usage = PROPERTY_USAGE_SUBGROUP
			})
			props.append({
				"name": "follow_target_node",
				"type": TYPE_NODE_PATH,
				"hint": PROPERTY_HINT_NODE_TYPE,
				"hint_string": "Node3D",

			})
		TrackingType.ANGLE:
			props.append({
				name = "Angle Target",
				type = TYPE_NIL,
				hint_string = "angle_target_",
				usage = PROPERTY_USAGE_SUBGROUP
			})
			props.append({
				"name": "angle_target_degrees_x",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-180,180,0.1",
			})
			props.append({
				"name": "angle_target_degrees_y",
				"type": TYPE_FLOAT,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "-90,90,0.1"
			})
			props.append({
				"name": "relative_to_travel_direction",
				"type": TYPE_BOOL
			})

	return props

func _ready() -> void:
	add_child(target)
	follow_target = get_node_or_null(follow_target_node)

	length = self.curve.get_baked_length()
	if speed > 0:
		time_to_finish = length / speed

	if length == 0.0:
		zero_length = true
