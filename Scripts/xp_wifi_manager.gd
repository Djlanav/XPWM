extends Control
class_name XPWifiManager


@onready var wlan_api: WlanAPI = $WlanAPI
@onready var networks_list: VBoxContainer = %NetworksContainer
@onready var refresh_timer: Timer = $RefreshTimer


var wifi_entry_scene := preload("uid://bhaepryhfj0y6")
var wifi_entry_shader := preload("uid://j3eomwo8xfqk")


func _ready() -> void:
	if is_instance_valid(wlan_api):
		print("[MANAGER] WLAN API Instance is valid")
	else:
		push_error("[MANAGER] WLAN API INSTANCE IS NOT VALID!")
		get_tree().quit()
	
	var networks = networks_list.get_children()
	for network in networks:
		network.queue_free()
	
	wlan_api.fetch_network_data()


func refresh() -> void:
	wlan_api.scan_networks()
	refresh_timer.start()
	await refresh_timer.timeout
	wlan_api.refresh_network_data()


func _on_wlan_api_network_data_fetched() -> void:
	var networks = wlan_api.get_networks()
	var ssids := networks.keys()
	
	for ssid in ssids:
		var wifi_entry := wifi_entry_scene.instantiate() as WiFiEntry
		wifi_entry.set_ssid(ssid)
		
		networks_list.add_child(wifi_entry)
		print("[WLAN] SSID Found: ", ssid)


func _on_child_exiting_tree(node: Node) -> void:
	if node is WlanAPI:
		wlan_api.close_wlan_handle()


func _on_task_panel_refresh_requested() -> void:
	var networks = networks_list.get_children()
	for network in networks:
		network.queue_free()
	
	refresh()
