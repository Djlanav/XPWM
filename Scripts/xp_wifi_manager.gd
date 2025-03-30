extends Control
class_name XPWifiManager


@onready var wlan_api: WlanAPI = $WlanAPI
@onready var networks_list: VBoxContainer = %NetworksContainer
@onready var refresh_timer: Timer = $RefreshTimer
@onready var no_wifi: Control = %NoWifiFound


var wifi_entry_scene := preload("uid://bhaepryhfj0y6")
var wifi_entry_shader := preload("uid://j3eomwo8xfqk")


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


func refresh(run_timer: bool) -> void:
	wlan_api.scan_networks()
	
	if run_timer:
		refresh_timer.start()
		await refresh_timer.timeout
	
	wlan_api.refresh_network_data()


func _on_wlan_api_network_data_fetched() -> void:
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
