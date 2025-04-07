extends Button


func _on_xp_wifi_manager_connection_status_updated(status: XPWifiManager.ConnectivityStatus) -> void:
	var wifi_entry := Globals.get_selected_network()
	if is_instance_valid(wifi_entry):
		match status:
			XPWifiManager.ConnectivityStatus.Disconnected:
				set_text("Connect")
			XPWifiManager.ConnectivityStatus.ConnectionComplete:
				if wifi_entry.connecting:
					set_text("Disconnect")
