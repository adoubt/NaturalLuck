extends Control
var balance: float = 1132.0:
	set(value):
		balance = value
		update_balance()
		
var relicts : Array[Relic]
var consumables : Array[Consumable]


var chosen_animals: Array[Animal]
var hand_animals: Array[Animal]
var enemies:Array[Enemy]
var chosen_enemies: Array[Enemy]
var chosen_hints: Array[Hint]
var hints: Array[Hint]
var showed_hints:Array[Hint]
var free_hints: int = 1
var current_round:int = 0
var deposit_ratio: float = 0.1
var debt:float
var enemy_instance: PackedScene = preload("res://src/scenes/enemy.tscn")
var hint_instance: PackedScene = preload("res://src/scenes/hint.tscn")
var animal_instance: PackedScene = preload("res://src/scenes/animal.tscn")
var stage: Stage = Stage.ROUND_START
var db = DataBase.new()
var tutorial_tween: Tween
var tutorial_busy := false	

@onready var battle_button:= %Battle
enum Stage {
	ROUND_START,
	PLAYER_SELECT,
	PLAYER_READY,
	BATTLE,
	REWARDS,
	ROUND_END,
	SHOP,
}

func _ready() -> void:

	await set_stage(Stage.ROUND_START)
	
func next_stage():
	match stage:
		Stage.ROUND_START:
			await set_stage(Stage.PLAYER_SELECT)

		Stage.PLAYER_SELECT:
			await set_stage(Stage.PLAYER_READY)
		Stage.PLAYER_READY:
			await set_stage(Stage.BATTLE)
		Stage.BATTLE:
			await set_stage(Stage.REWARDS)
		Stage.REWARDS:
			await set_stage(Stage.SHOP)
		Stage.SHOP:
			await set_stage(Stage.ROUND_END)
		
func set_stage(new_stage: Stage) -> void:
	stage = new_stage
	%Stage.text = str(stage)
	show_stage_text_tutorial()
	match stage:
		Stage.ROUND_START:
			disable_battle_button()
			await start_round()

		Stage.PLAYER_SELECT:
			enable_hand_selection()

		Stage.PLAYER_READY:
			enable_battle_button()

		Stage.BATTLE:
			disable_battle_button()
			await start_battle()

		Stage.REWARDS:
			await calc_rewards()

		Stage.SHOP:
			await open_shop()

		Stage.ROUND_END:
			await finalize_round()

func start_round():
	current_round += 1
	
	chosen_animals.clear()
	#used_consumables.clear()
	
	
	chosen_enemies = await generate_enemies(2)
	await wait_sec(0.4)
	chosen_hints = await generate_hints(3)
	hand_animals = await generate_hand(5)
	show_available_hints()
	next_stage()
	
func enable_battle_button():
	%Battle.disabled = false
	%DepositRatio.scrollable = true
	%DepositRatio.editable = true

func disable_battle_button():
	#%Battle.hide()
	%Battle.disabled = true
	#%DepositRatio.hide()
	%DepositRatio.scrollable = false
	%DepositRatio.editable = false
		
func calc_rewards():
	pass
	
func generate_enemies(count: int) -> Array[Enemy]:
	var result: Array[Enemy] = []

	for child in %EnemySlots.get_children():
		child.queue_free()

	var keys = db.enemy_configs.keys()

	for i in range(count):
		var id = keys[randi() % keys.size()]
		var e_data = db.enemy_configs[id]

		var new_enemy: Enemy = enemy_instance.instantiate()
		new_enemy.id = id
		new_enemy.icon_path = e_data["icon"]
		new_enemy.hide()
		%EnemySlots.add_child(new_enemy)

		await get_tree().process_frame
		new_enemy.play_spawn()

		await wait_sec(0.18)

		result.append(new_enemy)

	return result
	
func generate_hints(count: int) -> Array[Hint]:
	var result: Array[Hint] = []

	for child in %HintSlots.get_children():
		child.queue_free()

	var keys = db.hint_configs.keys()

	for i in range(count):
		var id = keys[randi() % keys.size()]
		var e_data = db.hint_configs[id]

		var new_hint: Hint = hint_instance.instantiate()
		new_hint.id = id
		new_hint.description = e_data["description"]
		new_hint.abilities = e_data["abilities"]

		if i >= free_hints:
			new_hint.visible = false
		else:
			new_hint.visible = true

		%HintSlots.add_child(new_hint)
		result.append(new_hint)

	return result
	
func generate_hand(count: int) -> Array[Animal]:
	var result: Array[Animal] = []

	for child in %HandSlots.get_children():
		child.queue_free()

	var keys = db.animal_configs.keys()

	for i in range(count):
		var id = keys[randi() % keys.size()]
		var e_data = db.animal_configs[id]

		var new_animal: Animal = animal_instance.instantiate()
		new_animal.id = id
		new_animal.icon_path = e_data["icon"]
		new_animal.description = e_data["description"]
		new_animal.abilities = e_data["abilities"]

		new_animal.hide()
		%HandSlots.add_child(new_animal)

		await get_tree().process_frame
		new_animal.play_spawn()

		await wait_sec(0.12)

		result.append(new_animal)

	return result

func show_available_hints():
	for i in range(chosen_hints.size()):
		chosen_hints[i].visible = i < free_hints


func reveal_hint():
	free_hints = min(free_hints + 1, chosen_hints.size())
	show_available_hints()
	
func open_shop():
	pass
	
func run_battle():
	for animal in chosen_animals:
		# удар
		await wait_sec(0.25)

	for enemy in chosen_enemies:
		# ответка
		await wait_sec(0.25)

	await wait_sec(0.5)
			
func start_battle():
	await wait_sec(0.25)
	split_deposit()
	await run_battle()
	await set_stage(Stage.REWARDS)
	
	
func finalize_round():
	for child in %HintSlots.get_children():
		child.queue_free()
	for child in %EnemySlots.get_children():
		child.queue_free()
	for child in %AnimalSlots.get_children():
		child.queue_free()
	set_stage(Stage.ROUND_START)

func enable_hand_selection():
	# активировать UI руки
	# игрок выбирает до 3 животных
	pass
	
func on_confirm_selection():
	await set_stage(Stage.PLAYER_READY)		

	
func split_deposit():
	var round_deposit:float = (balance * deposit_ratio)
	for animal in chosen_animals:
		animal.balance += round_deposit/chosen_animals.size()


func _on_h_slider_value_changed(value: float) -> void:
	deposit_ratio = value


func _on_next_pressed() -> void:
	await next_stage()
func wait_sec(time: float) -> void:
	await get_tree().create_timer(time).timeout
	
func refresh_chosen_animals():
	chosen_animals.clear()

	for child in %AnimalSlots.get_children():
		if child is Animal:
			chosen_animals.append(child)
	if chosen_animals.size() >= 3:
		set_stage(Stage.PLAYER_READY)		
	
		


func show_stage_text_tutorial() -> void:
	#await wait_sec(1.4)
	var label: RichTextLabel = %Tutorial
	var msg := get_stage_text(stage)

	if tutorial_tween:
		tutorial_tween.kill()

	tutorial_busy = true

	label.show()
	label.modulate.a = 1.0
	label.text = msg
	label.visible_characters = 0

	var total := label.get_total_character_count()

	tutorial_tween = create_tween()

	tutorial_tween.tween_property(
		label,
		"visible_characters",
		total,
		max(1.6, total * 0.015)
	)

	tutorial_tween.tween_interval(3.0)
	tutorial_tween.tween_property(label, "modulate:a", 0.0, 0.25)

	await tutorial_tween.finished

	label.hide()
	tutorial_busy = false
func update_balance() -> void:
	%Balance.bbcode_enabled = true
	%Balance.text = "[center][wave amp=3 freq=1.6][color=#5dff7a]$%s[/color][/wave][/center]" % str(int(balance))

func get_stage_text(stage: Stage) -> String:
	match stage:
		Stage.ROUND_START:
			return ""
			return "[center][wave amp=3 freq=1.5][color=#ff6b7a]Pay the debt. Survive another round[/color][/wave][/center]"
		Stage.PLAYER_SELECT:
			return "[center][wave amp=6 freq=2.2][rainbow freq=0.35 sat=0.8 val=1]Choose up to 3 animals for the fight[/rainbow][/wave][/center]"

		Stage.PLAYER_READY:
			return "[center][wave amp=6 freq=2.0][rainbow freq=0.32 sat=0.8 val=1]Set your deposit then start the battle[/rainbow][/wave][/center]"

		Stage.BATTLE:
			return "[center][wave amp=8 freq=2.6][rainbow freq=0.45 sat=0.9 val=1]The clash begins no more changes[/rainbow][/wave][/center]"

		Stage.REWARDS:
			return "[center][wave amp=5 freq=1.9][rainbow freq=0.28 sat=0.75 val=1]Collect rewards and prepare ahead[/rainbow][/wave][/center]"

		Stage.ROUND_END:
			return "[center][wave amp=4 freq=1.7][rainbow freq=0.22 sat=0.6 val=0.95]Round complete the pressure rises[/rainbow][/wave][/center]"

		Stage.SHOP:
			return "[center][wave amp=7 freq=2.3][rainbow freq=0.38 sat=0.85 val=1]Visit the shop and buy an advantage[/rainbow][/wave][/center]"

	return ""
