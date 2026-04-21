extends Control
class_name Enemy

var id: int
var icon_path: String
var rate :float
var payout:float
var description: String = ""
@onready var sprite = $Visual/TextureRect
@onready var visual = $Visual
var tween

func _ready():
	sprite.texture = load(icon_path)
	tooltip_text = description

func play_spawn():
	show()

	visual.position.x = 500
	visual.modulate.a = 0.0
	visual.scale = Vector2(0.9, 0.9)
	if tween: tween.kill()
	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(visual, "position", Vector2.ZERO, 0.45)
	tween.tween_property(visual, "modulate:a", 1.0, 0.25)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.35)
