extends Node

var selected_network: WiFiEntry

func set_selected_network(network: WiFiEntry) -> void:
	selected_network = network


func get_selected_network() -> WiFiEntry:
	return selected_network


func notify_unimplemented_feature() -> void:
	Win32API.show_info_message_box(
				"Unimplemented", 
				"This feature is not yet implemented!")
