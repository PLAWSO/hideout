class_name KeyIntPair

var key: String
var value: int

func _init(value_value: int, key_value: String) -> void:
	self.value = value_value
	self.key = key_value

func as_text() -> String:
	return "%s: %d" % [key, value]