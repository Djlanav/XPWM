extends Node

var selected_network: WiFiEntry

func set_selected_network(network: WiFiEntry) -> void:
	selected_network = network


func get_selected_network() -> WiFiEntry:
	return selected_network
