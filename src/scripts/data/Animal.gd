extends Control
class_name Animal

var abilities: Array = []
var balance: float = 0.0
var repeat_count = 0
var requeue_count = 0
var id: int
var description: String = ""
var icon_idle_path: String = ""
var icon_happy_path: String = ""
var icon_sad_path: String = ""
var animal_name: String
@onready var balance_label: RichTextLabel = $AnimalBalance
@onready var delta_layer: Control = $DeltaLayer
@onready var visual: Control = $Visual
@onready var texture_rect: TextureRect = $Visual/TextureRect
@export var max_scale: float = 1.1     
@export var min_scale: float = 0.5

var balance_float_tween: Tween

func _process(_delta: float) -> void:
	update_perspective_scale()
	
func update_perspective_scale() -> void:
	if not is_inside_tree():
		return
	
	var viewport_height = get_viewport_rect().size.y
	var center_y = viewport_height * 0.5
	
	# Нормализуем позицию: 
	# -1.0 = сильно сверху,  +1.0 = сильно снизу
	var t = (global_position.y - center_y) / (viewport_height * 0.5)   # 0.35 = насколько сильно влияет высота
	
	t = clamp(t, -1.0, 1.0)
	
	# Интерполяция от min_scale (сверху) к max_scale (снизу)
	var scale_factor = lerp(min_scale, max_scale, (t + 1.0) / 2.0)
	
	visual.scale = Vector2.ONE * scale_factor
func _ready() -> void:
	custom_minimum_size = Vector2(128, 128)
	size = Vector2(128, 128)

	mouse_filter = Control.MOUSE_FILTER_STOP

	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.position = Vector2.ZERO
	visual.size = size

	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.size = size

	if icon_idle_path != "":
		texture_rect.texture = load(icon_idle_path)

	balance_label.visible = false

	hide()


func update_balance(amount: float, fine:bool = false) -> void:
	balance += amount
	
	show_delta(amount)
	change_mood(amount, fine)
	if balance <= 0:
		balance = 0
		balance_label.visible = false
		return

	balance_label.visible = true
	balance_label.bbcode_enabled = true
	balance_label.text = (
		"[center]" +
		"[wave amp=4 freq=2.2]" +
		"[color=#5dff7a]$%d[/color]" % int(balance) +
		"[/wave]" +
		"[/center]"
	)

	play_balance_popup()
	start_balance_idle_float()
	
	
func change_mood(amount: float,fine:bool = false):
	if amount > 0:
		texture_rect.texture = load(icon_happy_path)
	elif amount < 0 and !fine :
		texture_rect.texture = load(icon_sad_path)
	#else: texture_rect.texture = load(icon_idle_path)
	
func play_balance_popup() -> void:
	if balance_float_tween:
		balance_float_tween.kill()

	balance_label.modulate.a = 0.0
	balance_label.scale = Vector2(0.7, 0.7)
	balance_label.position = Vector2(0, 0)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(balance_label, "modulate:a", 1.0, 0.18)

	tween.tween_property(
		balance_label,
		"position:y",
		-20,
		0.28
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		balance_label,
		"scale",
		Vector2.ONE,
		0.24
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func start_balance_idle_float() -> void:
	await get_tree().create_timer(0.30).timeout

	if not is_instance_valid(balance_label):
		return

	balance_float_tween = create_tween()
	balance_float_tween.set_loops()

	balance_float_tween.tween_property(
		balance_label,
		"position:y",
		-28,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	balance_float_tween.tween_property(
		balance_label,
		"position:y",
		-20,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func show_delta(amount: float) -> void:
	if amount == 0:
		return

	var label := RichTextLabel.new()

	label.bbcode_enabled = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.fit_content = true

	label.custom_minimum_size = Vector2(120, 36)
	label.size = Vector2(120, 36)
	label.position = Vector2(4, -10)

	var value := int(abs(amount))

	if amount > 0:
		label.text = (
			"[center][wave amp=3 freq=2]" +
			"[color=#5dff7a]+$%d[/color]" % value +
			"[/wave][/center]"
		)
	else:
		label.text = (
			"[center][wave amp=3 freq=2]" +
			"[color=#ff5d5d]-$%d[/color]" % value +
			"[/wave][/center]"
		)

	delta_layer.add_child(label)

	label.modulate.a = 0.0
	label.scale = Vector2(0.8, 0.8)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(label, "modulate:a", 1.0, 0.10)
	tween.tween_property(label, "position:y", -42, 0.55)
	tween.tween_property(label, "scale", Vector2.ONE, 0.18)

	tween.chain().tween_property(label, "modulate:a", 0.0, 0.22)

	await tween.finished
	label.queue_free()
	
func play_spawn() -> void:
	show()

	visual.position = Vector2(0, 250)
	visual.modulate = Color(1, 1, 1, 0)
	visual.scale = Vector2(0.5, 0.5)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(visual, "position", Vector2.ZERO, 0.40)
	tween.tween_property(visual, "modulate:a", 1.0, 0.22)
	tween.tween_property(visual, "scale", Vector2.ONE, 0.30)


func _get_drag_data(at_position: Vector2):
	if not visible:
		return null
	var game = get_tree().get_first_node_in_group("game")
	if not game.can_grab():
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



func _can_drop_data(_pos, data):
	
	if not get_parent():
		return false
	elif get_parent().name == "AnimalSlots":
		var count = get_parent().get_child_count()
		if data in get_parent().get_children():
			count-=1
		return data is Animal and count < 3
	elif get_parent().name == "HandSlots":
		return data is Animal
		
func _drop_data(_pos, data):
	if data == self:
		return
	if data.get_parent():
		data.get_parent().remove_child(data)
	
	
	get_parent().add_child(data)
	

	data.reset_visual_state()

	var game = get_tree().get_first_node_in_group("game")
	game.refresh_chosen_animals()
	game.refresh_hand_animals()
