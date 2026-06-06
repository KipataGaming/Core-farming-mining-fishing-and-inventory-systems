extends CanvasLayer

@onready var output = $Panel/VBoxContainer/RichTextLabel
@onready var input = $Panel/VBoxContainer/LineEdit

func _ready() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_console"):
		visible = !visible
		if visible:
			input.grab_focus()

func _on_line_edit_text_submitted(text: String) -> void:
	log_message("> " + text)
	process_command(text)
	input.clear()

func log_message(message: String) -> void:
	output.append_text(message + "\n")

func process_command(command: String) -> void:
	var parts = command.split(" ")
	match parts[0]:
		"help":
			log_message("Available commands: help, set_stamina <value>, give_all")
		"set_stamina":
			if parts.size() > 1:
				Data.stamina = float(parts[1])
				log_message("Stamina set to " + parts[1])
		"give_all":
			for item in Data.items.keys():
				Data.items[item] = max(Data.items[item], 1)
			log_message("All items set to at least 1.")
		_:
			log_message("Unknown command: " + parts[0])
