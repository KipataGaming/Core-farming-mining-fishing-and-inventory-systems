extends CanvasLayer

func _ready() -> void:
	get_tree().paused = true
	$CenterContainer/VBoxContainer/ResumeButton.grab_focus()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_quit_desktop_button_pressed() -> void:
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_resume_button_pressed()
		get_viewport().set_input_as_handled()
