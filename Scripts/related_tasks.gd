extends Control
class_name RelatedTasks


@onready var learn_more_button: RichTextLabel = %LearnMoreLabel
@onready var preferred_order_button: RichTextLabel = %PreferredOrderLabel
@onready var advanced_settings_button: RichTextLabel = %AdvancedSettingsLabel 


var learn_more_focused: bool
var preferred_order_focused: bool
var advanced_settings_focused: bool


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if learn_more_focused and event.is_pressed():
			Globals.notify_unimplemented_feature()
		elif preferred_order_focused and event.is_pressed():
			Globals.notify_unimplemented_feature()
		elif advanced_settings_focused and event.is_pressed():
			Globals.notify_unimplemented_feature()


# Mouse Enter
func _on_learn_more_label_mouse_entered() -> void:
	var new_text = learn_more_button.text.insert(0, "[u]")
	learn_more_button.set_text(new_text)
	learn_more_focused = true


func _on_preferred_order_label_mouse_entered() -> void:
	var new_text = preferred_order_button.text.insert(0, "[u]")
	preferred_order_button.set_text(new_text)
	preferred_order_focused = true


func _on_advanced_settings_label_mouse_entered() -> void:
	var new_text = advanced_settings_button.text.insert(0, "[u]")
	advanced_settings_button.set_text(new_text)
	advanced_settings_focused = true


# Mouse Exit
func _on_learn_more_label_mouse_exited() -> void:
	var new_string = learn_more_button.text.replace("[u]", "")
	learn_more_button.set_text(new_string)
	learn_more_focused = false


func _on_preferred_order_label_mouse_exited() -> void:
	var new_string = preferred_order_button.text.replace("[u]", "")
	preferred_order_button.set_text(new_string)
	preferred_order_focused = false


func _on_advanced_settings_label_mouse_exited() -> void:
	var new_string = advanced_settings_button.text.replace("[u]", "")
	advanced_settings_button.set_text(new_string)
	advanced_settings_focused = false
