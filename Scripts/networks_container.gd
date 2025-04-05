extends VBoxContainer


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if !get_global_rect().has_point(event.global_position):
			return
		
		var clicked_entry: WiFiEntry = null
		for entry: WiFiEntry in get_children():
			if entry.get_global_rect().has_point(event.global_position):
				clicked_entry = entry
				break
			
		if clicked_entry:
			if Globals.get_selected_network():
				var selected_entry := Globals.get_selected_network()
				selected_entry.deselect()
			clicked_entry.select()
		else:
			if Globals.get_selected_network():
				var selected_entry := Globals.get_selected_network()
				selected_entry.deselect()
