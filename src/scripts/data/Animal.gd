extends Control
class_name Animal

var abilities: Array = []
var balance: float = 0.0
var id: int
var description: String = ""
var icon_path: String = ""

@onready var visual: Control = $Visual
@onready var texture_rect: TextureRect = $Visual/TextureRect


func _ready() -> void:
	custom_minimum_size = Vector2(128, 128)
	size = Vector2(128, 128)

	mouse_filter = Control.MOUSE_FILTER_STOP

	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.position = Vector2.ZERO
	visual.size = size

	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.size = size

	if icon_path != "":
		texture_rect.texture = load(icon_path)

	hide()


func play_spawn() -> void:
	show()

	visual.position = Vector2(0, 250)
	visual.modulate = Color(1, 1, 1, 0)
	visual.scale = Vector2(0.9, 0.9)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(visual, "position", Vector2.ZERO, 0.40)
	tween.tween_property(visual, "modulate:a", 1.0, 0.22)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.30)


func _get_drag_data(at_position: Vector2):
	if not visible:
		return null

	var preview := Control.new()
	preview.custom_minimum_size = size
	preview.size = size
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tex := TextureRect.new()
	tex.texture = texture_rect.texture
	tex.size = size
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.modulate = Color(1, 1, 1, 0.85)

	# сохраняем точку захвата
	tex.position = -at_position

	preview.add_child(tex)

	set_drag_preview(preview)

	modulate.a = 0.45
	return self


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		modulate.a = 1.0


func move_to_container(target: Control) -> void:
	var old_parent := get_parent()

	if old_parent:
		old_parent.remove_child(self)

	target.add_child(self)


func reset_visual_state() -> void:
	modulate.a = 1.0
	scale = Vector2.ONE
	visual.position = Vector2.ZERO
	visual.scale = Vector2.ONE
	visual.modulate = Color.WHITE
