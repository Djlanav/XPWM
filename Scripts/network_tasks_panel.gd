extends Control
class_name NetworkTasks


signal refresh_requested


@onready var refresh_button: RichTextLabel = %RefreshLabel
@onready var setup_button: RichTextLabel = %SetupWirelessLabel


var refresh_focused: bool
var setup_focused: bool


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and refresh_focused:
		if event.is_pressed():
			refresh_requested.emit()


func _on_refresh_mouse_entered() -> void:
	var new_text = refresh_button.text.insert(0, "[u]")
	refresh_button.set_text(new_text)
	refresh_focused = true


func _on_refresh_mouse_exited() -> void:
	var new_string = refresh_button.text.replace("[u]", "")
	refresh_button.set_text(new_string)
	refresh_focused = false


func _on_setup_wireless_mouse_entered() -> void:
	var new_text = setup_button.text.insert(0, "[u]")
	setup_button.set_text(new_text)
	setup_focused = true


func _on_setup_wireless_mouse_exited() -> void:
	var new_string = setup_button.text.replace("[u]", "")
	setup_button.set_text(new_string)
	setup_focused = false
