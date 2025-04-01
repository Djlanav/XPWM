extends ColorRect
class_name WiFiEntry


signal selected(ssid: String)


@onready var ssid_label: Label = $SSID
@onready var wifi_security: Control = $WifiSecurity
@onready var security_label: Label = $WifiSecurity/SecurityLabel
@onready var security_icon: TextureRect = $WifiSecurity/SecurityIcon
@onready var signal_strength: TextureRect = $SignalStrength
@onready var connection_status: Label = $ConnectionStatus
@onready var connected_star: TextureRect = $ConnectedStar
@onready var connect_ready: Label = $ConnectReady
@onready var border_panel: Panel = $Panel


var zero_bars := preload("uid://dkfei5jl0lsyn")
var one_bar := preload("uid://dr1q5vx2cvh6f")
var two_bars := preload("uid://ep20ee4mnn64")
var three_bars := preload("uid://dhcphn3pusqtw")
var four_bars := preload("uid://dsmrkjkuy7snw")
var full_bars := preload("uid://c7hb0lggsp1fx")


var focused: bool = false
var shader_material: ShaderMaterial


func _ready() -> void:
	shader_material = get_material()
	shader_material.set_shader_parameter("top_color", Color(0.770548, 0.831494, 0.963489, 1))
	shader_material.set_shader_parameter("bottom_color", Color(0.4, 0.537255, 0.866667, 1))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and focused:
			selected.emit(ssid_label.get_text())
			
			set_instance_shader_parameter("enabled", false)
			Globals.set_selected_network(self)
			connect_ready.show()
			set_full_custom_minimum_size(Vector2(0.0, 137.0))
			set_text_color(Color.WHITE)
		
		if event.is_pressed() and not focused:
			set_instance_shader_parameter("enabled", true)
			connect_ready.hide()
			set_full_custom_minimum_size(Vector2(0.0, 60.0))
			set_text_color(Color.BLACK)


func set_full_custom_minimum_size(new_size: Vector2) -> void:
	set_custom_minimum_size(new_size)
	border_panel.set_custom_minimum_size(new_size)


func set_text_color(new_color: Color) -> void:
	security_label.label_settings.font_color = new_color
	ssid_label.label_settings.font_color = new_color
	connection_status.label_settings.font_color = new_color


func set_ssid(ssid: String) -> void:
	$SSID.set_text(ssid)


func get_ssid() -> String:
	return $SSID.get_text()


func check_security(is_secure: bool) -> void:
	if not is_secure:
		security_label.set_text("Unsecured wireless network")
		security_label.set_position(Vector2(10.0, 0.0))
		security_icon.hide()


func set_connected() -> void:
	connected_star.show()
	
	connection_status.set_text("Connected")
	connection_status.set_position(Vector2(415.0, 5.0))
	connection_status.show()


func set_acquiring() -> void:
	connection_status.set_text("Acquiring network address")
	connection_status.set_position(Vector2(374.0, 5.0))
	connection_status.show()


func hide_connection_status() -> void:
	connected_star.hide()
	connection_status.hide()


func show_connection_status() -> void:
	connected_star.show()
	connection_status.show()


func set_signal_strength(bars: int) -> void:
	match bars:
		0:
			signal_strength.set_texture(zero_bars)
		1:
			signal_strength.set_texture(one_bar)
		2:
			signal_strength.set_texture(two_bars)
		3:
			signal_strength.set_texture(three_bars)
		4:
			signal_strength.set_texture(four_bars)
		_:
			signal_strength.set_texture(full_bars)
			
			


func _on_connection_status_updated(status: XPWifiManager.ConnectivityStatus) -> void:
	match status:
		XPWifiManager.ConnectivityStatus.ConnectionStart:
			set_acquiring()
		XPWifiManager.ConnectivityStatus.ConnectionComplete:
			set_connected()


func _on_began_connecting() -> void:
	connection_status.set_text("Not Connected")
	connection_status.show()


func _on_mouse_entered() -> void:
	focused = true


func _on_mouse_exited() -> void:
	focused = false
