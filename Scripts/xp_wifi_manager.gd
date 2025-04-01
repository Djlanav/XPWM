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


@onready var wlan_api: WlanAPI = $WlanAPI
@onready var networks_list: VBoxContainer = %NetworksContainer
@onready var refresh_timer: Timer = $RefreshTimer
@onready var no_wifi: Control = %NoWifiFound
@onready var scroll_bar: VScrollBar = $WifiList/VScrollBar
@onready var scroll_container: ScrollContainer = $WifiList/ScrollContainer


var wifi_entry_scene := preload("uid://bhaepryhfj0y6")
var wifi_entry_shader := preload("uid://j3eomwo8xfqk")


var connecting: bool


func _ready() -> void:
	if is_instance_valid(wlan_api):
		print("[MANAGER] WLAN API Instance Is Valid")
	else:
		push_error("[MANAGER] WLAN API INSTANCE IS NOT VALID!")
		get_tree().quit()
	
	var networks = networks_list.get_children()
	for network in networks:
		network.queue_free()
	
	refresh(false)


func _process(_delta: float) -> void:
	var connection_status := wlan_api.poll_connection_status() as String
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
	
	if networks_list.get_child_count() >= 7:
		scroll_bar.show()
		scroll_container.set_deferred("scroll_vertical", scroll_bar.get_value())
	else:
		scroll_bar.hide()


func refresh(run_timer: bool) -> void:
	wlan_api.scan_networks()
	
	if run_timer:
		refresh_timer.start()
		await refresh_timer.timeout
	
	wlan_api.refresh_network_data()


func _on_wlan_api_network_data_fetched() -> void:
	print_debug("Data fetched?")
	var networks := wlan_api.get_networks() as Dictionary
	
	for net_ssid: String in networks:
		var network: WiFiNetwork = networks[net_ssid]
		var connected_ssid := wlan_api.check_connectivity()
	
		var wifi_entry := wifi_entry_scene.instantiate() as WiFiEntry
		wifi_entry.set_ssid(net_ssid)
		networks_list.add_child(wifi_entry)
		
		if net_ssid == connected_ssid:
			wifi_entry.set_connected()
		else:
			wifi_entry.hide_connection_status()
		
		wifi_entry.check_security(network.secured)
		wifi_entry.set_signal_strength(network.bars)
		print("[WLAN] SSID Found: ", net_ssid)
	
	no_wifi.hide()


func _on_child_exiting_tree(node: Node) -> void:
	if node is WlanAPI:
		wlan_api.close_wlan_handle()


func _on_task_panel_refresh_requested() -> void:
	var networks = networks_list.get_children()
	for network in networks:
		network.queue_free()
	
	refresh(false)


func _on_wifi_entry_selected(ssid: String) -> void:
	pass


func _on_connect_pressed() -> void:
	connecting = true
	began_connecting.emit()
	
	var wifi_entry := Globals.get_selected_network()
	
	if is_instance_valid(wifi_entry):
		var ssid := wifi_entry.get_ssid()
		print("[WLAN] Connecting to ", ssid)
