extends Label
class_name Hint

var id: int
var abilities:Array = []
var description:String
func _ready() -> void:
	text = description
