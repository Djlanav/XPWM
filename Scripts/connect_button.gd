extends Button


func _ready() -> void:
	WlanAPI.disconnected.connect(_on_wlan_disconnected)
	WlanAPI.connection_complete.connect(_on_wlan_connection_complete)


func _on_wlan_disconnected() -> void:
	set_text("Connect")


func _on_wlan_connection_complete() -> void:
	var wifi_entry := Globals.get_selected_network()
	if not is_instance_valid(wifi_entry):
		return
	
	if wifi_entry.connecting:
		set_text("Disconnect")
