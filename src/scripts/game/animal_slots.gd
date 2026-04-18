extends MarginContainer
func _can_drop_data(_pos, data):
	return data is Animal and %AnimalSlots.get_child_count() < 3


func _drop_data(_pos, data):
	if data.get_parent():
		data.get_parent().remove_child(data)

	%AnimalSlots.add_child(data)

	data.reset_visual_state()

	var game = get_tree().get_first_node_in_group("game")
	game.refresh_chosen_animals()
