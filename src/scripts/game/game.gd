extends Control
var _balance: float = 100.0
var balance: float:
	get:
		return _balance
	set(value):
		var delta := value - _balance
		_balance = value
		update_balance()

		if delta != 0:
			show_balance_delta(delta)

var game_data = {
	"balance": 100,
	"rounds": {}
}
var relics : Array[Relic]
var consumables : Array[Consumable]
var max_enemies:int = 2
var game_speed :float= 1
var chosen_animals: Array[Animal]
var hand_animals: Array[Animal]
var enemies:Array[Enemy]
var chosen_enemies: Array[Enemy]
var chosen_hints: Array[Hint]
var hints: Array[Hint]
var showed_hints:Array[Hint]
var free_hints: int = 1
var bonus_hints:Array=[]
var music_player := AudioStreamPlayer.new()
var ui_player:= AudioStreamPlayer.new()
var goal:float = 150.0:
	set(value):
		goal = value
		round_goal+=5
		%GoalLabel.text = "Pay Debt $"+str(int(value))+" by Round "+ str(round_goal)
var round_goal:int = 0
var current_round:int = 0:
	set(value):
		current_round = value
		%RoundLabel.text = "Round "+ str(value)
var queue:Array[Animal]

var deposit_ratio: float = 0.1
var debt:float
var enemy_instance: PackedScene = preload("res://src/scenes/enemy.tscn")
var hint_instance: PackedScene = preload("res://src/scenes/hint.tscn")
var animal_instance: PackedScene = preload("res://src/scenes/animal.tscn")
var stage: Stage = Stage.ROUND_START
var db = DataBase.new()
var tutorial_tween: Tween
var tutorial_busy := false	
var last_played:Array[Animal]
var last_played_unit: int

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
func _on_music_finished():
	music_player.play()
func _ready() -> void:
	%DeathScreen.visible= false
	%Repeat.hide()
	goal = 150
	update_deposit_size()
	%DepositSize.hide()
	update_balance()
	await set_stage(Stage.ROUND_START)
	hand_animals = await generate_hand(5)
	%AnimalsField.i(self)
	%HandSlots.i(self)
	add_child(ui_player)
	
	add_child(music_player)
	music_player.stream = preload("res://src/assets/sounds/music/theme.mp3")
	#music_player.bus = "Music"
	music_player.volume_db = -20
	music_player.autoplay = false
	music_player.finished.connect(_on_music_finished)

	music_player.play()
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
			await set_stage(Stage.ROUND_END)
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
			save_game()
		Stage.PLAYER_SELECT:
			enable_hand_selection()
			save_game()
		Stage.PLAYER_READY:
			enable_battle_button()
			save_game()
		Stage.BATTLE:
			disable_battle_button()
			await start_battle()
			save_game()
		Stage.REWARDS:
			await calc_rewards()
			save_game()
		Stage.SHOP:
			await open_shop()
			save_game()
		Stage.ROUND_END:
			await finalize_round()
			save_game()
func start_round():
	change_light()
	current_round += 1
	
	refresh_chosen_animals()
	#used_consumables.clear()
	
	chosen_enemies = await generate_enemies(randf_range(1, max_enemies))
	await wait_sec(0.4 / game_speed)
	
	
	chosen_hints = await generate_hints(3)
	await refresh_chosen_hints()
	show_available_hints()
	bonus_hints.clear()
	send_event(AbilityTriggers.Events.ROUND_STARTED, {})
	#%ChosenAnimalSlots.modulate.a = 0.9
	await next_stage()
	
func enable_battle_button():
	%Battle.disabled = false
	%DepositRatio.scrollable = true
	%DepositRatio.editable = true
	update_deposit_size()
	%DepositSize.show()
	
func disable_battle_button():
	#%Battle.hide()
	%Battle.disabled = true
	#%DepositRatio.hide()
	%DepositRatio.scrollable = false
	%DepositRatio.editable = false
		
func calc_rewards():
	await refresh_hand_animals()
	var animals_to_process = hand_animals.duplicate()
	for animal in animals_to_process:
		if is_instance_valid(animal):
			await money_back(animal)
	await next_stage()
	
func generate_enemies(count: int) -> Array[Enemy]:
	var result: Array[Enemy] = []
	var keys = db.enemy_configs.keys()

	for i in range(count):
		var id = keys[randi() % keys.size()]
		var e_data = db.enemy_configs[id]

		var new_enemy: Enemy = enemy_instance.instantiate()
		new_enemy.id = id
		new_enemy.icon_path = e_data["icon"]
		new_enemy.rate =  e_data["rate"]
		new_enemy.payout = e_data["payout"]
		new_enemy.description = e_data["description"]
		new_enemy.hide()
		%EnemySlots.add_child(new_enemy)

		await get_tree().process_frame
		
		new_enemy.play_spawn()
		

		await wait_sec(0.18/ game_speed)

		result.append(new_enemy)

	return result
	
func generate_hints(count: int) -> Array[Hint]:
	var result: Array[Hint] = []
	

	for id in bonus_hints:
		var new_hint = create_hint_logic(id)
		

		new_hint.visible = true 
		
		%HintSlots.add_child(new_hint)
		new_hint.visible = true
		result.append(new_hint)


	
	var keys = db.hint_configs.keys()
	for i in range(count):
		var id = keys[randi() % keys.size()]
		var new_hint = create_hint_logic(id)
		
		
		if i < free_hints:
			new_hint.visible = true
		else:
			new_hint.visible = false
			
		%HintSlots.add_child(new_hint)
		result.append(new_hint)
	await refresh_chosen_hints()
	await save_game()
	return result

# Вспомогательная функция, чтобы не дублировать код настройки
func create_hint_logic(id: int) -> Hint:
	var e_data = db.hint_configs[id]
	var inst: Hint = hint_instance.instantiate()
	inst.id = id
	inst.description = e_data["description"]
	inst.abilities = e_data["abilities"]
	return inst
	
func generate_hand(count: int) -> Array[Animal]:
	var result: Array[Animal] = []

	for child in %HandSlots.get_children():
		child.queue_free()
	
	var keys = db.animal_configs.keys()
	keys.shuffle()

	count = min(count, keys.size())

	for i in range(count):
		var id = keys[i]
		var e_data = db.animal_configs[id]

		var new_animal: Animal = animal_instance.instantiate()
		new_animal.id = id
		new_animal.animal_name = e_data["name"]
		new_animal.icon_idle_path = e_data["icon_idle"]
		new_animal.icon_happy_path = e_data["icon_happy"]
		new_animal.icon_sad_path = e_data["icon_sad"]
		new_animal.description = e_data["description"]
		new_animal.abilities = e_data["abilities"]

		new_animal.hide()
		%HandSlots.add_child(new_animal)
		
		await get_tree().process_frame

		if is_instance_valid(new_animal):
			new_animal.play_spawn()

		await wait_sec(0.12 / game_speed)

		result.append(new_animal)
	await refresh_hand_animals()
	return result

func show_available_hints():
	for i in range(chosen_hints.size()):
		chosen_hints[i].visible = i < free_hints + bonus_hints.size()
	
#
#func reveal_hint():
	#free_hints = min(free_hints + 1, chosen_hints.size())
	#show_available_hints()
	
func open_shop():
	pass
	
func run_battle() -> void:
	
	last_played = []
	queue = chosen_animals.duplicate()
	var ctx = {
		"queue": queue,
		"player_balance": balance,
		"last_played": last_played
	}
	send_event(AbilityTriggers.Events.BATTLE_STARTED, ctx)

	queue.reverse()

	while queue.size() > 0:
		var animal: Animal = queue.pop_front()

		if animal == null:
			continue

		if animal.balance <= 0:
			await wait_sec(0.3 / game_speed)
			animal.move_to_container(%HandSlots)
			continue

		await run_enemy_chain(animal)

		while animal.balance > 0 and animal.repeat_count > 0:
			animal.repeat_count -= 1
			await run_enemy_chain(animal)

		animal.reset_visual_state()

		if animal.balance > 0 and animal.requeue_count > 0:
			animal.requeue_count -= 1
			queue.append(animal)
			await animal_move_to(
				animal,
				%AnimalSlots.global_position,
				0.3 / game_speed
			)

			
		else:
			await animal_move_to(
				animal,
				animal.global_position + Vector2(0, 100),
				0.2 / game_speed
			)

			animal.reparent(%HandSlots)
			last_played.append(animal)

	await wait_sec(0.5 / game_speed)
	queue.clear()
	
func run_enemy_chain(animal: Animal) -> void:
	for enemy in chosen_enemies:

		if animal.balance <= 0:
			break

		var target_global := get_attack_position(animal, enemy)

		await animal_move_to(
			animal,
			target_global,
			0.35 / game_speed
		)

		await wait_sec(0.15 / game_speed)

		var win := roll_vs_rate(enemy.rate)
		var ctx:= {"source":animal, "target": enemy}
		if win:
			var total_payout = enemy.payout * animal.balance
			send_event(AbilityTriggers.Events.ANIMAL_WIN,ctx)
			animal.update_balance(total_payout)
		else:
			send_event(AbilityTriggers.Events.ANIMAL_LOSS,ctx)
			animal_lose_balance(animal)
		
		send_event(AbilityTriggers.Events.ENEMY_PASSED, ctx)
		await wait_sec(0.45 / game_speed)

func get_attack_position(animal: Animal, enemy: Enemy) -> Vector2:
	return Vector2(
		enemy.global_position.x - animal.size.x - 30,
		enemy.global_position.y
	)

func animal_move_to(animal: Animal, target_global: Vector2, time: float) -> void:
	var old_global := animal.global_position

	animal.reparent(%FXLayer)
	animal.global_position = old_global

	var tween := create_tween()

	tween.tween_property(
		animal,
		"global_position",
		target_global,
		time
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	await tween.finished

var lose_streak := 0

func roll_vs_rate(rate: float) -> bool:
	if rate >= 1.0:
		return true

	var bonus := lose_streak * 0.04
	var final_rate :float= clamp(rate + bonus, 0.0, 0.99)

	var win :bool= randf() <= final_rate

	if win:
		lose_streak = 0
	else:
		lose_streak += 1

	return win				
func start_battle():
	#%ChosenAnimalSlots.modulate.a = 0.0
	await wait_sec(0.25 / game_speed)
	await split_deposit()
	await wait_sec(1.0 / game_speed)
	await run_battle()
	await set_stage(Stage.REWARDS)
	
	
func finalize_round():
	save_game()
	for child in %HintSlots.get_children():
		child.queue_free()
	for child in %EnemySlots.get_children():
		child.queue_free()
	for child in %AnimalSlots.get_children():
		child.queue_free()
		
	await get_tree().process_frame
	%Repeat.show()
	await  set_stage(Stage.ROUND_START)
	if current_round == round_goal:
		check_goal()
	
func check_goal():
	if _balance < goal:
		play_death()
		
	else: 
		goal*=4
		max_enemies+=1
func enable_hand_selection():
	# активировать UI руки
	# игрок выбирает до 3 животных
	pass
	
	
func on_confirm_selection():
	await set_stage(Stage.PLAYER_READY)		

	
func split_deposit():
	%DepositSize.hide()
	var round_deposit:float = (balance * deposit_ratio)
	
	balance -= round_deposit
	
	update_deposit_size()
	var amount = round_deposit/chosen_animals.size()
	
	for animal in chosen_animals:
		
			
		animal.update_balance(amount)
		var ctx:={"amount":amount, "source":animal,"target":animal}
		send_event(AbilityTriggers.Events.DEPOSITED,ctx)
func _on_h_slider_value_changed(value: float) -> void:
	deposit_ratio = value
	update_deposit_size()


func update_deposit_size() -> void:
	var amount := int(balance * deposit_ratio)

	var scale_size: float = lerp(22.0, 72.0, deposit_ratio)
	var wave_amp: float = lerp(1.0, 47.0, deposit_ratio)
	var wave_freq: float = lerp(1.0, 13.0, deposit_ratio)

	%DepositSize.bbcode_enabled = true
	%DepositSize.text = (
		"[center]" +
		"[wave amp=%d freq=%.2f]" % [int(wave_amp), wave_freq] +
		"[font_size=%d]" % int(scale_size) +
		"[color=#5dff7a]$%d[/color]" % amount +
		"[/font_size][/wave][/center]"
	)

	var slider := %DepositRatio
	var bubble := %DepositBubble

	var t := inverse_lerp(
		slider.min_value,
		slider.max_value,
		slider.value
	)

	var x :float= t * slider.size.x

	bubble.position.x = slider.position.x + x - bubble.size.x * 0.5
	bubble.position.y = slider.position.y - 10

func _on_next_pressed() -> void:
	await next_stage()
func wait_sec(time: float) -> void:
	await get_tree().create_timer(time).timeout
	
func refresh_chosen_animals():
	chosen_animals.clear()

	for child in %AnimalSlots.get_children():
		if child is Animal:
			chosen_animals.append(child)
	if chosen_animals.size()  > 0 and (stage not in [Stage.BATTLE]):
		enable_battle_button()
		
	if chosen_animals.size() >= 3 and (stage  in [Stage.PLAYER_SELECT, Stage.ROUND_START]) :
		await set_stage(Stage.PLAYER_READY)		

func refresh_chosen_hints():
	chosen_hints.clear()

	for child in %HintSlots.get_children():
		if child is Hint:
			chosen_hints.append(child)
		
func refresh_hand_animals():
	hand_animals.clear()
	for child in %HandSlots.get_children():
		if child is Animal:
			hand_animals.append(child)

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

	tutorial_tween.tween_interval(10.0)
	tutorial_tween.tween_property(label, "modulate:a", 0.0, 0.25)

	await tutorial_tween.finished

	label.hide()
	tutorial_busy = false
func update_balance() -> void:
	%Balance.bbcode_enabled = true
	%Balance.text = (
		"[center][wave amp=3 freq=1.6]" +
		"[color=#5dff7a]$%d[/color]" % round(_balance) +
		"[/wave][/center]"
	)
	
func show_balance_delta(delta: float) -> void:
	var label := RichTextLabel.new()

	label.bbcode_enabled = true
	label.scroll_active = false
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	label.custom_minimum_size = Vector2(50, 50)
	label.size = Vector2(50, 50)

	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF

	label.position = Vector2(0, 0)

	var amount := int(abs(delta))

	if delta > 0:
		label.text = "[center][color=#5dff7a]+$%d[/color][/center]" % amount
	else:
		label.text = "[center][color=#ff5d5d]-$%d[/color][/center]" % amount

	%BalanceDeltaLayer.add_child(label)

	label.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(label, "modulate:a", 1.0, 0.12)
	tween.tween_property(label, "position:y", 28, 0.7)
	tween.chain().tween_property(label, "modulate:a", 0.0, 0.22)

	await tween.finished
	label.queue_free()
	
func get_stage_text(stage: Stage) -> String:
	match stage:
		Stage.ROUND_START:
			return ""
			return "[center][wave amp=3 freq=1.5][color=#ff6b7a]Pay the debt. Survive another round[/color][/wave][/center]"
		Stage.PLAYER_SELECT:
			return "[center][wave amp=6 freq=2.2][rainbow freq=0.35 sat=0.8 val=1]Choose up to 3 animals for the fight. Add them to the field on the left.
[/rainbow][/wave][/center]"

		Stage.PLAYER_READY:
			return "[center][wave amp=6 freq=2.0][rainbow freq=0.32 sat=0.8 val=1]Set your deposit then start the battle[/rainbow][/wave][/center]"

		Stage.BATTLE:
			return "[center][wave amp=8 freq=2.6][rainbow freq=0.45 sat=0.9 val=1]The battle begins![/rainbow][/wave][/center]"

		Stage.REWARDS:
			return "[center][wave amp=5 freq=1.9][rainbow freq=0.28 sat=0.75 val=1]prepare ahead[/rainbow][/wave][/center]"

		Stage.ROUND_END:
			return "[center][wave amp=4 freq=1.7][rainbow freq=0.22 sat=0.6 val=0.95]Round complete the pressure rises[/rainbow][/wave][/center]"

		Stage.SHOP:
			return "[center][wave amp=7 freq=2.3][rainbow freq=0.38 sat=0.85 val=1]Visit the shop and buy an advantage[/rainbow][/wave][/center]"

	return ""


func _on_battle_pressed() -> void:
	await set_stage(Stage.BATTLE)
	
	
func can_grab() -> bool:
	return stage == Stage.ROUND_START or stage == Stage.PLAYER_SELECT or stage == Stage.PLAYER_READY


func _on_repeat_pressed() -> void:
	await repeat_last_played()
	
func repeat_last_played()->void:
	if stage not in [Stage.PLAYER_SELECT] or last_played.is_empty():
		return

	chosen_animals.clear()
	for animal in %AnimalSlots.get_children():
		if is_instance_valid(animal):
			animal_move_to(animal, animal.global_position+ Vector2(0,100), 0.3/game_speed)
			animal.move_to_container(%HandSlots)
			await refresh_hand_animals()
	for animal in last_played:
		if not is_instance_valid(animal):
			continue
		await animal_move_to(animal, %AnimalSlots.global_position,0.3/game_speed)
		animal.move_to_container(%AnimalSlots)
		chosen_animals.append(animal)
		await refresh_chosen_animals()
	await wait_sec(0.3 / game_speed)
	await set_stage(Stage.BATTLE)


func change_light() -> void:
	var colors := [
		Color("#0B2B26"),
		Color("#14311C"),
		Color("#1F3B3D"),
		Color("#225A4B"),
		Color("#2A4930"),
		Color("#262B15"),
		Color("#384B49"),
		Color("#1F2B29")
	]
	
	var random_color = colors[randi() % colors.size()]
	
	var tween := create_tween()
	tween.tween_property(%RoundLight, "color", random_color, 1.2)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(%RoundLight, "energy", randf_range(0.6, 1.1), 1.2)

func save_game():
	game_data["rounds"][current_round] = {
		"hints": chosen_hints,
		"relics": relics,
		"deposit_percent": deposit_ratio,
		"last_played":[last_played],
		"last_played_unit": last_played_unit,
	}

func money_back(animal: Animal) -> void:
	var ctx = {"target": animal, "amount": animal.balance}
	await send_event(AbilityTriggers.Events.BEFORE_ANIMAL_CASHOUT, ctx)

	animal.update_balance(-ctx["amount"]) 
	balance += ctx["amount"]

func animal_lose_balance(animal: Animal) -> void:
	var ctx = {"target": animal, "amount": animal.balance}
	send_event(AbilityTriggers.Events.BEFORE_ANIMAL_CASHOUT, ctx)
	
	
	animal.update_balance(-ctx["amount"])

func send_event(event_type: int, ctx: Dictionary) -> void:
	

	for animal in chosen_animals:	
		for ab_id in animal.abilities:
			var ab = db.animal_abilities[ab_id]
			
			if ab.trigger == event_type:
				if is_target_valid(animal, ab, ctx):
					execute_ability(ab, animal, ctx)
	for hint in chosen_hints:	
		for ab_id in hint.abilities:
			var ab = db.hint_abilities[ab_id]
			
			if ab.trigger == event_type:
				if is_target_valid(hint, ab, ctx):
			
					execute_ability(ab, hint, ctx)

func is_target_valid(target: Node, ab: Dictionary, ctx: Dictionary) -> bool:
	match ab.target:
		AbilityTriggers.Targets.ANIMAL:
			
			return target == ctx.get("target")
		AbilityTriggers.Targets.ENEMY:
			
			return target == ctx.get("source")
		
		AbilityTriggers.Targets.SELF:
			
			return true
		AbilityTriggers.Targets.GAME:	
			return true
		AbilityTriggers.Targets.NEXT_ANIMAL:
			return queue.size()>0
	return false		

func execute_ability(ab: Dictionary, source: Node, ctx: Dictionary) -> void:
	
	match ab.action:
		
		AbilityTriggers.Actions.KEEP_PERCENT:
			if ctx.get("target") == source:
				if ctx.has("amount"):
					ctx["amount"] *= (1.0 - ab.value)
					
		AbilityTriggers.Actions.SHARE_PERCENT:
			var next_animal = queue.front()
			
			
			next_animal.update_balance(source.balance * ab.value)
			
		AbilityTriggers.Actions.ADD_REQUEUE:
			source.requeue_count += ab.value
			
		AbilityTriggers.Actions.SHOW_LAST_SIGNAL:
			var first_hint_id = chosen_hints[0].id
			bonus_hints.append(first_hint_id)
			
		AbilityTriggers.Actions.INCREASE_RATE:
			var enemy :Enemy = ctx["target"]
			enemy.rate+= ab.value
		AbilityTriggers.Actions.INCREASE_ALL_PAYOUT:
			for enemy in chosen_enemies:
				
				enemy.payout+= ab.value
		AbilityTriggers.Actions.ADD_ENEMY_BALANCE:
			var animal: Animal = ctx["target"]
			if animal in last_played:
				print(last_played)
				await wait_sec(0.5/game_speed)
				await animal.update_balance(ctx["amount"] *ab.value)

func play_death():
	ui_player.stream = preload("res://src/assets/sounds/ui/death.mp3")
	ui_player.volume_db = -20
	ui_player.play()
	%DeathScreen.visible = true
	%CenterPanel.visible = false
	var mat := %DeathScreen.get_child(0).material as ShaderMaterial
	mat.set_shader_parameter("Alpha", 0.1)

	var tween = create_tween()
	tween.tween_method(
		func(value): mat.set_shader_parameter("Alpha", value),
		0.1,
		3.0,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()



func _on_game_speed_value_changed(value: float) -> void:
	Engine.time_scale =value


func _on_sound_value_changed(value: float) -> void:
	if value <= 0.01:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			-80
		)
	else:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Master"),
			linear_to_db(value)
		)
