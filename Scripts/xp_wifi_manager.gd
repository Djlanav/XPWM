extends Control
class_name XPWifiManager


enum ConnectivityStatus {
	ConnectionStart,
	ConnectionComplete,
	ConnectionAttemptFail,
	Disconnected,
	Unknown
}


signal connection_status_updated(status: ConnectivityStatus)
signal began_connecting


@onready var networks_list: VBoxContainer = %NetworksContainer
@onready var refresh_timer: Timer = $RefreshTimer
@onready var no_wifi: Control = %NoWifiFound
@onready var scroll_bar: VScrollBar = $WifiList/VScrollBar
@onready var scroll_container: ScrollContainer = $WifiList/ScrollContainer
@onready var connect_button: Button = $WifiList/Connect


var wifi_entry_scene := preload("uid://bhaepryhfj0y6")
var wifi_entry_shader := preload("uid://j3eomwo8xfqk")


var connecting: bool


func _ready() -> void:
	WlanAPI.network_data_fetched.connect(_on_wlan_api_network_data_fetched)
	
	var networks = networks_list.get_children()
	for network in networks:
		network.queue_free()
	
	WlanAPI.read_from_known_networks()
	#refresh(false)


func _process(_delta: float) -> void:
	var connection_status: Variant = WlanAPI.poll_connection_status()
	if connection_status != null:
		match_status(connection_status)
	
	if networks_list.get_child_count() >= 7:
		scroll_bar.show()
		scroll_container.set_deferred("scroll_vertical", scroll_bar.get_value())
	else:
		scroll_bar.hide()


func match_status(connection_status: String) -> void:
	match connection_status:
		"ConnectionStart":
			connection_status_updated.emit(ConnectivityStatus.ConnectionStart)
		"ConnectionComplete":
			connection_status_updated.emit(ConnectivityStatus.ConnectionComplete)
		"ConnectionAttemptFail":
			connection_status_updated.emit(ConnectivityStatus.ConnectionAttemptFail)
		"Disconnected":
			connection_status_updated.emit(ConnectivityStatus.Disconnected)
		"Unknown":
			connection_status_updated.emit(ConnectivityStatus.Unknown)


func refresh(run_timer: bool) -> void:
	WlanAPI.scan_networks()
	
	if run_timer:
		refresh_timer.start()
		await refresh_timer.timeout
	
	WlanAPI.check_for_active_connection()
	WlanAPI.refresh_network_data()


func _on_wlan_api_network_data_fetched() -> void:
	var networks := WlanAPI.get_networks() as Dictionary
	
	for net_ssid: String in networks:
		var network: WiFiNetwork = networks[net_ssid]
		var connected_ssid: Variant = WlanAPI.get_connected_ssid()
		if is_instance_valid(connected_ssid):
			connected_ssid = connected_ssid as String
	
		var wifi_entry := wifi_entry_scene.instantiate() as WiFiEntry
		wifi_entry.set_ssid(net_ssid)
		networks_list.add_child(wifi_entry)
		
		if net_ssid == connected_ssid:
			wifi_entry.set_connected()
			WlanAPI.add_network_to_known_networks(wifi_entry.get_ssid())
		else:
			wifi_entry.hide_connection_status()
		
		wifi_entry.check_security(network.secured)
		wifi_entry.set_signal_strength(network.bars)
		
		connection_status_updated.connect(wifi_entry._on_connection_status_updated)
		wifi_entry.selected.connect(_on_wifi_entry_selected)
		print("[WLAN] SSID Found: ", net_ssid)
	
	no_wifi.hide()


func _on_task_panel_refresh_requested() -> void:
	var networks = networks_list.get_children()
	for network in networks:
		network.queue_free()
	
	refresh(false)


func _on_wifi_entry_selected(connected: bool) -> void:
	if connected:
		connect_button.set_text("Disconnect")
	else:
		connect_button.set_text("Connect")


func _on_connect_pressed() -> void:
	var wifi_entry := Globals.get_selected_network()
	if is_instance_valid(wifi_entry):
		if wifi_entry.connected:
			WlanAPI.disconnect()
		else:
			pass
