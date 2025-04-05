extends Panel
class_name PasswordWindow


signal connection_aborted
signal credentials_provided(password: String)


@onready var network_password: LineEdit = $BackgroundPanel/NetworkPassword
@onready var confirm_password: LineEdit = $BackgroundPanel/NetworkPassword2
@onready var connect_button: Button = $BackgroundPanel/Connect
@onready var cancel: Button = $BackgroundPanel/Cancel


var dragging := false
var drag_offset := Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_global_rect().has_point(event.global_position):
				dragging = true
				drag_offset = event.global_position - global_position
			elif not event.pressed:
				dragging = false
				
	elif event is InputEventMouseMotion and dragging:
		global_position = event.global_position - drag_offset


func _on_connect_pressed() -> void:
	var password := network_password.get_text()
	var confirm := confirm_password.get_text()
	
	if password != confirm:
		Win32API.show_error_message_box(
			"Wireless Configuration", 
			"The network keys you typed do not match. \nPlease reenter the network key in the confirmation text box.")
	else:
		credentials_provided.emit(password)
		hide()


func _on_cancel_pressed() -> void:
	connection_aborted.emit()
	hide()


func _on_close_button_pressed() -> void:
	connection_aborted.emit()
	hide()


func _on_xp_wifi_manager_began_connecting() -> void:
	show()
