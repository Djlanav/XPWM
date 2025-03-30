extends ColorRect
class_name WiFiEntry


@onready var wifi_security: Control = $WifiSecurity
@onready var security_label: Label = $WifiSecurity/SecurityLabel
@onready var security_icon: TextureRect = $WifiSecurity/SecurityIcon
@onready var signal_strength: TextureRect = $SignalStrength
@onready var connection_status: Label = $ConnectionStatus
@onready var connected_star: TextureRect = $ConnectedStar


var zero_bars := preload("uid://dkfei5jl0lsyn")
var one_bar := preload("uid://dr1q5vx2cvh6f")
var two_bars := preload("uid://ep20ee4mnn64")
var three_bars := preload("uid://dhcphn3pusqtw")
var four_bars := preload("uid://dsmrkjkuy7snw")
var full_bars := preload("uid://c7hb0lggsp1fx")


func set_ssid(ssid: String):
	$SSID.set_text(ssid)


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


func hide_connection_status() -> void:
	connected_star.hide()
	connection_status.hide()


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
			
			
