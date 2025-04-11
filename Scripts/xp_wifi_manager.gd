extends Control
class_name XPWifiManager


enum ConnectivityStatus {
	ConnectionStart,
	ConnectionComplete,
	ConnectionAttemptFail,
	Disconnected,
	Unknown
}


signal began_connecting(connecting_ssid: String)
signal request_password(connecting_ssid: String)


@onready var networks_list: VBoxContainer = %NetworksContainer
@onready var refresh_timer: Timer = $RefreshTimer
@onready var no_wifi: Control = %NoWifiFound
@onready var scroll_bar: VScrollBar = %VScrollBar
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var connect_button: Button = $WifiList/Connect
@onready var password_window: PasswordWindow = %PasswordWindow
@onready var connection_timer: Timer = $ConnectionTimer


@export_multiline var profiles_found_warning: String


var wifi_entry_scene := preload("uid://bhaepryhfj0y6")
var wifi_entry_shader := preload("uid://j3eomwo8xfqk")


var connecting: bool


func _ready() -> void:
	get_viewport().get_window().title = "Wireless Network Connection"
	
	WlanAPI.network_data_fetched.connect(_on_wlan_api_network_data_fetched)
	WlanAPI.windows_profiles_found.connect(_on_windows_profiles_found)
	
	WlanAPI.initialize_network_manager()
	WlanAPI.check_for_windows_profiles()
	
	var networks = networks_list.get_children()
	for network in networks:
		network.queue_free()
	
	WlanAPI.read_from_known_networks()
	#refresh(false)


func _process(_delta: float) -> void:
	WlanAPI.poll_connection_status()
	if networks_list.get_child_count() >= 7:
		scroll_bar.show()
		scroll_container.set_deferred("scroll_vertical", scroll_bar.get_value())
	else:
		pass
		scroll_bar.hide()


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
		
		began_connecting.connect(wifi_entry._on_began_connecting)
		password_window.connection_aborted.connect(wifi_entry._on_connection_aborted)
		
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
			var ssid = wifi_entry.get_ssid()
			if not WlanAPI.check_for_matching_profile(ssid):
				request_password.emit(ssid)
			else:
				connect_to_network(ssid)


func _on_password_window_credentials_provided(ssid: String, password: String) -> void:
	WlanAPI.generate_profile(ssid, password)
	connect_to_network(ssid)


func connect_to_network(ssid: String) -> void:
	#connection_timer.start()
	#await connection_timer.timeout
	
	WlanAPI.connect(ssid)


func _on_password_window_visibility_changed() -> void:
	if password_window.is_visible():
		connect_button.set_disabled(true)
	else:
		connect_button.set_disabled(false)


func _on_windows_profiles_found(ssid: String) -> void:
	if Win32API.show_yes_no_warning("Windows Profiles Found", profiles_found_warning):
		WlanAPI.delete_profile(ssid)


#func _on_testxmlbutton_pressed() -> void:
	#WlanAPI.test_xml_data("Linksys77")
	#WlanAPI.generate_profile("Linksys77", "Baspios377")
