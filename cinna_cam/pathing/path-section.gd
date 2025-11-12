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

func _get_property_list():
	var props = []

	match tracking_type:
		TrackingType.FOLLOW:
			props.append({
				"name": "follow_target_node",
				"type": TYPE_NODE_PATH,
				"hint": PROPERTY_HINT_NODE_TYPE,
				"hint_string": "Node3D",

			})
		TrackingType.ANGLE:
			props.append({
				"name": "angle_target",
				"type": TYPE_VECTOR3
			})

	return props

var follow_target: Node3D = null
var follow_target_node: NodePath = NodePath()
var angle_target: Vector3 = Vector3.ZERO

var zero_length: bool = false
var length: float = 0.0

var target: PathFollow3D= PathFollow3D.new()

func _ready() -> void:
	add_child(target)
	follow_target = get_node_or_null(follow_target_node)

	length = self.curve.get_baked_length()
	if speed > 0:
		time_to_finish = length / speed

	if length == 0.0:
		zero_length = true

	
	

func _get(property: StringName):
	match property:
		"follow_target_node":
			return follow_target_node
		"angle_target":
			return angle_target
	return null

func _set(property: StringName, value) -> bool:
	print("Setting property: " + str(property) + " to value: " + str(value))
	match property:
		"follow_target_node":
			follow_target_node = value
			return true
		"angle_target":
			angle_target = value
			return true
	return false