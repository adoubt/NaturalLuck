extends MarginContainer

var game
func i(_game: Node) -> void:
	game= _game
	
func _can_drop_data(_pos, data):
	var count = %AnimalSlots.get_child_count()
	if data in %AnimalSlots.get_children():
		count -=1
	return data is Animal and count < 3


func _drop_data(_pos, data):
	#if data.get_parent():
		#data.get_parent().remove_child(data)
	await game.animal_move_to(data, %AnimalSlots.global_position + (%AnimalSlots.size/2), 0.3/game.game_speed)
	#%AnimalSlots.add_child(data)
	data.move_to_container(%AnimalSlots)
	#data.reparent(%AniimalSlots)
	data.reset_visual_state()

	
	game.refresh_chosen_animals()
	game.refresh_hand_animals()
