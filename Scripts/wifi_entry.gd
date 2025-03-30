extends ColorRect
class_name WiFiEntry


func _ready() -> void:
	pass


func set_ssid(ssid: String):
	$SSID.set_text(ssid)
