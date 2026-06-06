extends CanvasLayer
var TOOL_TEXTURES = {}
var SEED_TEXTURES = {}

var tool_texture_scene = preload("res://scenes/ui/tool_ui_texture.tscn")

@onready var tool_container = $Control/Panel/ToolContainer
@onready var seed_container = $Control/Panel/SeedContainer

func _ready() -> void:
	TOOL_TEXTURES = {
		Enum.Tool.AXE: preload("res://graphics/icons/axe.png"),
		Enum.Tool.HOE: preload("res://graphics/icons/hoe.png"),
		Enum.Tool.WATER: preload("res://graphics/icons/water.png"),
		Enum.Tool.SWORD: preload("res://graphics/icons/sword.png"),
		Enum.Tool.FISH: preload("res://graphics/icons/fishingrod.png"),
		Enum.Tool.SEED: preload("res://graphics/icons/wheat.png"),
		Enum.Tool.PICKAXE: preload("res://graphics/icons/pickaxe.png")}
	SEED_TEXTURES = {
		Enum.Seed.CORN: preload("res://graphics/icons/corn.png"),
		Enum.Seed.PUMPKIN: preload("res://graphics/icons/pumpkin.png"),
		Enum.Seed.TOMATO: preload("res://graphics/icons/tomato.png"),
		Enum.Seed.WHEAT: preload("res://graphics/icons/wheat.png")}

	tool_container.show()
	seed_container.hide()
	texture_setup(Enum.Tool.values(), TOOL_TEXTURES, tool_container)
	texture_setup(Enum.Seed.values(), SEED_TEXTURES, seed_container)
	
	setup_status_ui()

func texture_setup(enum_list: Array, textures: Dictionary, container: HBoxContainer):
	for enum_id in enum_list:
		if textures.has(enum_id):
			var tool_texture = tool_texture_scene.instantiate()
			tool_texture.setup(enum_id, textures[enum_id])
			container.add_child(tool_texture)

func reveal(tool: bool):
	var current_container = tool_container if tool else seed_container
	var target = get_parent().current_tool if tool else get_parent().current_seed
	
	tool_container.hide()
	seed_container.hide()
	current_container.show()
	
	for texture in current_container.get_children():
		texture.highlight(target == texture.tool_enum)

func setup_status_ui() -> void:
	# 1. Setup Status Bars (Health and Stamina) at bottom right
	var status_container = VBoxContainer.new()
	status_container.name = "StatusContainer"
	status_container.custom_minimum_size = Vector2(180, 50)
	status_container.add_theme_constant_override("separation", 2)
	
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.12, 0.12, 0.12, 0.7)
	sb_bg.set_corner_radius_all(3)
	
	# Health Bar
	var hp_lbl = Label.new()
	hp_lbl.name = "HP"
	hp_lbl.text = "HP"
	hp_lbl.add_theme_font_size_override("font_size", 10)
	hp_lbl.self_modulate = Color(0.9, 0.9, 0.9)
	status_container.add_child(hp_lbl)
	
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(180, 10)
	var sb_health = StyleBoxFlat.new()
	sb_health.bg_color = Color(0.85, 0.15, 0.25)
	sb_health.set_corner_radius_all(3)
	health_bar.add_theme_stylebox_override("background", sb_bg)
	health_bar.add_theme_stylebox_override("fill", sb_health)
	status_container.add_child(health_bar)
	
	# Stamina Bar
	var energy_lbl = Label.new()
	energy_lbl.name = "Energy"
	energy_lbl.text = "Energy"
	energy_lbl.add_theme_font_size_override("font_size", 10)
	energy_lbl.self_modulate = Color(0.9, 0.9, 0.9)
	status_container.add_child(energy_lbl)
	
	var stamina_bar = ProgressBar.new()
	stamina_bar.name = "StaminaBar"
	stamina_bar.show_percentage = false
	stamina_bar.custom_minimum_size = Vector2(180, 10)
	var sb_stamina = StyleBoxFlat.new()
	sb_stamina.bg_color = Color(0.1, 0.75, 0.45)
	sb_stamina.set_corner_radius_all(3)
	stamina_bar.add_theme_stylebox_override("background", sb_bg)
	stamina_bar.add_theme_stylebox_override("fill", sb_stamina)
	status_container.add_child(stamina_bar)
	
	$Control.add_child(status_container)
	status_container.anchor_left = 1.0
	status_container.anchor_top = 1.0
	status_container.anchor_right = 1.0
	status_container.anchor_bottom = 1.0
	status_container.offset_left = -200
	status_container.offset_top = -110
	status_container.offset_right = -20
	status_container.offset_bottom = -10

	# 2. Setup Clock Panel at top right
	var clock_panel = PanelContainer.new()
	clock_panel.name = "ClockPanel"
	clock_panel.custom_minimum_size = Vector2(120, 60)
	var sb_clock = StyleBoxFlat.new()
	sb_clock.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	sb_clock.set_corner_radius_all(6)
	sb_clock.border_width_left = 2
	sb_clock.border_width_top = 2
	sb_clock.border_width_right = 2
	sb_clock.border_width_bottom = 2
	sb_clock.border_color = Color(0.2, 0.2, 0.2)
	clock_panel.add_theme_stylebox_override("panel", sb_clock)
	
	var clock_layout = VBoxContainer.new()
	clock_layout.name = "ClockLayout"
	clock_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var day_lbl = Label.new()
	day_lbl.name = "DayLabel"
	day_lbl.text = "Day 1"
	day_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_lbl.add_theme_font_size_override("font_size", 12)
	clock_layout.add_child(day_lbl)
	
	var time_lbl = Label.new()
	time_lbl.name = "TimeLabel"
	time_lbl.text = "05:30"
	time_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_lbl.add_theme_font_size_override("font_size", 18)
	time_lbl.self_modulate = Color(1.0, 0.9, 0.5)
	clock_layout.add_child(time_lbl)
	
	clock_panel.add_child(clock_layout)
	$Control.add_child(clock_panel)
	
	clock_panel.anchor_left = 1.0
	clock_panel.anchor_top = 0.0
	clock_panel.anchor_right = 1.0
	clock_panel.anchor_bottom = 0.0
	clock_panel.offset_left = -140
	clock_panel.offset_top = 20
	clock_panel.offset_right = -20
	clock_panel.offset_bottom = 80

	# 3. Setup Notification Label at top center
	var notification_label = Label.new()
	notification_label.name = "NotificationLabel"
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.add_theme_font_size_override("font_size", 16)
	notification_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	notification_label.hide()
	$Control.add_child(notification_label)
	
	notification_label.anchor_left = 0.5
	notification_label.anchor_top = 0.2
	notification_label.anchor_right = 0.5
	notification_label.anchor_bottom = 0.2
	notification_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	notification_label.offset_left = -300
	notification_label.offset_right = 300

func show_notification(text: String, duration: float = 4.0) -> void:
	if not has_node("Control/NotificationLabel"):
		return
	var notif = $Control/NotificationLabel
	notif.text = text
	notif.show()
	notif.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_interval(duration - 1.0)
	tween.tween_property(notif, "modulate:a", 0.0, 1.0)
	tween.tween_callback(notif.hide)

func _process(_delta: float) -> void:
	if has_node("Control/ClockPanel/ClockLayout/DayLabel"):
		get_node("Control/ClockPanel/ClockLayout/DayLabel").text = "Day %d" % Data.day
	if has_node("Control/ClockPanel/ClockLayout/TimeLabel"):
		get_node("Control/ClockPanel/ClockLayout/TimeLabel").text = Data.get_time_string()
		
	if has_node("Control/StatusContainer"):
		var h_bar = get_node("Control/StatusContainer/HealthBar") as ProgressBar
		var s_bar = get_node("Control/StatusContainer/StaminaBar") as ProgressBar
		var hp_lbl = get_node("Control/StatusContainer/HP") as Label
		var energy_lbl = get_node("Control/StatusContainer/Energy") as Label
		
		if h_bar:
			h_bar.value = Data.health
			h_bar.max_value = Data.max_health
		if s_bar:
			s_bar.value = Data.stamina
			s_bar.max_value = Data.max_stamina
			
		if hp_lbl:
			hp_lbl.text = "HP: %d/%d" % [int(Data.health), int(Data.max_health)]
		if energy_lbl:
			energy_lbl.text = "Energy: %d/%d" % [int(Data.stamina), int(Data.max_stamina)]
			
		var show_hp = Data.health < Data.max_health
		if h_bar: h_bar.visible = show_hp
		if hp_lbl: hp_lbl.visible = show_hp
