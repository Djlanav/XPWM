extends Control


var wifi_entry_scene := preload("uid://bhaepryhfj0y6")


func _ready() -> void:
	var entry := wifi_entry_scene.instantiate()
	$Panel.add_child(entry)
