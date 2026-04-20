extends GridContainer

var game
func i(_game: Node) -> void:
	game= _game
func _can_drop_data(_pos, data):
	return data is Animal


func _drop_data(_pos, data):
	if data.get_parent():
		data.get_parent().remove_child(data)

	add_child(data)

	data.reset_visual_state()

	
	game.refresh_chosen_animals()
	game.refresh_hand_animals()
