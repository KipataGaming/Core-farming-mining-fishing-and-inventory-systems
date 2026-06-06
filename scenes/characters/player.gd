extends CharacterBody2D

var direction: Vector2
var last_direction: Vector2
var speed := 50
var can_move: bool = true
@onready var move_state_machine = $Animation/AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine = $Animation/AnimationTree.get("parameters/ToolStateMachine/playback")
var current_tool: Enum.Tool = Enum.Tool.AXE
var current_seed: Enum.Seed
var current_state: Enum.State
var current_style: Enum.Style
var current_style_index: int
var current_machine: Enum.Machine
var current_machine_index: int
var god_mode: bool = false
@onready var tool_sounds = {
	Enum.Tool.AXE: $Sounds/Axe,
	Enum.Tool.SWORD: $Sounds/Axe,
	Enum.Tool.FISH: $Sounds/Fish,
	Enum.Tool.HOE: $Sounds/Hoe,
	Enum.Tool.SEED: $Sounds/Seed,
	Enum.Tool.WATER: $Sounds/Water,
	Enum.Tool.PICKAXE: $Sounds/Axe,
}

signal tool_use(tool: Enum.Tool, pos: Vector2)
signal diagnose
signal day_change
signal build(current_machine: Enum.Machine)
signal machine_change(current_machine: Enum.Machine)
signal close_shop

func _ready() -> void:
	$ToolUI.reveal(true)


func _physics_process(_delta: float) -> void:
	match current_state:
		Enum.State.DEFAULT:
			if can_move:
				get_basic_input()
				move()
				animate()
		Enum.State.FISHING:
			get_fishing_input()
		Enum.State.BUILDING:
			get_building_input()
			move()
			animate()
		Enum.State.SHOP:
			get_shopping_input()
	if direction:
		last_direction = direction
		var ray_y = int(direction.y) if not direction.x else 0
		$RayCast2D.target_position = Vector2(direction.x,ray_y).normalized() * 20
		
		if not $Sounds/StepTimer.time_left:
			$Sounds/StepTimer.start()
	else:
		$Sounds/StepTimer.stop()


func get_basic_input():
	for i in range(1, 8):
		if Input.is_action_just_pressed("tool_" + str(i)):
			# Assuming tools are 0-indexed in Enum.Tool. If Tool count is 7, max index is 6.
			var tool_index = i - 1
			if tool_index < Enum.Tool.size():
				current_tool = tool_index as Enum.Tool
				$ToolUI.reveal(true)
				# Removed ResourceUI visibility toggling

	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		current_tool = posmod(current_tool + int(dir), Enum.Tool.size()) as Enum.Tool
		$ToolUI.reveal(true)
		# Removed ResourceUI visibility toggling
	
	if Input.is_action_just_pressed("seed_forward"):
		# Using Enum.Seed.size() ensures we cycle through all available seeds
		current_seed = posmod(current_seed + 1, Enum.Seed.size()) as Enum.Seed
	
	if Input.is_action_just_pressed("action"):
		if not $RayCast2D.get_collider():
			if Data.TOOL_STATE_ANIMATIONS.has(current_tool):
				if Data.stamina <= 0 and not god_mode:
					if has_node("ToolUI") and $ToolUI.has_method("show_notification"):
						$ToolUI.show_notification("Too exhausted!")
					return
				tool_state_machine.travel(Data.TOOL_STATE_ANIMATIONS[current_tool])
				$Animation/AnimationTree.set("parameters/ToolOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		else:
			var collider = $RayCast2D.get_collider()
			if collider.has_method("interact"):
				collider.interact(self)
			else:
				if Data.TOOL_STATE_ANIMATIONS.has(current_tool):
					if Data.stamina <= 0 and not god_mode:
						if has_node("ToolUI") and $ToolUI.has_method("show_notification"):
							$ToolUI.show_notification("Too exhausted!")
						return
					tool_state_machine.travel(Data.TOOL_STATE_ANIMATIONS[current_tool])
					$Animation/AnimationTree.set("parameters/ToolOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	if Input.is_action_just_pressed("diagnose"):
		diagnose.emit()

	if Input.is_action_just_pressed("style_toggle"):
		current_style_index = posmod(current_style_index + 1, Data.unlocked_styles.size())
		current_style = Data.unlocked_styles[current_style_index] as Enum.Style
		$Sprite2D.texture = Data.PLAYER_SKINS[current_style]

	
	if Input.is_action_just_pressed("build"):
		current_state = Enum.State.BUILDING
		current_machine = Data.unlocked_machines[current_machine_index] as Enum.Machine
	
	if Input.is_key_pressed(KEY_G):
		god_mode = !god_mode
		if god_mode:
			for item in Data.items.keys():
				Data.items[item] = 999
		print("God mode: ", god_mode)


func hit_stop(duration: float = 0.1):
	get_tree().paused = true
	await get_tree().create_timer(duration, true, false, true).timeout
	get_tree().paused = false


func camera_shake(intensity: float = 2.0, duration: float = 0.2):
	if $Camera2D.has_method("shake"):
		$Camera2D.shake(intensity, duration)


func get_fishing_input():
	if Input.is_action_just_pressed("action"):
		$FishingGame.action()


func get_building_input():
	if Input.is_action_just_pressed("build"):
		current_state = Enum.State.DEFAULT
	
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var dir = Input.get_axis("tool_backward", "tool_forward")
		current_machine_index = posmod(current_machine_index + int(dir), Data.unlocked_machines.size())
		current_machine = Data.unlocked_machines[current_machine_index] as Enum.Machine
		machine_change.emit(current_machine)

	if Input.is_action_just_pressed("action"):
		build.emit(current_machine)


func get_shopping_input():
	if Input.is_action_just_pressed("ui_cancel"):
		close_shop.emit()
		get_tree().get_first_node_in_group("ResourceUI").hide()


func move():
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()


func animate():
	if direction:
		move_state_machine.travel('Walk')
		var direction_animation = Vector2(round(direction.x),round(direction.y))
		$Animation/AnimationTree.set("parameters/MoveStateMachine/Idle/blend_position", direction_animation)
		$Animation/AnimationTree.set("parameters/MoveStateMachine/Walk/blend_position", direction_animation)
		$Animation/AnimationTree.set("parameters/FishBlendSpace2D/blend_position", direction_animation)
		for animation in Data.TOOL_STATE_ANIMATIONS.values():
			var animation_name: String = "parameters/ToolStateMachine/"+ animation +"/blend_position"
			$Animation/AnimationTree.set(animation_name, direction_animation)
	else:
		move_state_machine.travel('Idle')


func start_fishing():
	$FishingGame.reveal()
	current_state = Enum.State.FISHING
	$Animation/AnimationTree.set("parameters/FishBlend/blend_amount", 1)


func stop_fishing():
	can_move = true
	current_state = Enum.State.DEFAULT
	$Animation/AnimationTree.set("parameters/FishBlend/blend_amount", 0)


func tool_use_emit():
	tool_use.emit(current_tool, position + last_direction * 16 + Vector2(0,4))
	tool_sounds[current_tool].play()
	
	if not god_mode:
		var stamina_cost = 0
		match current_tool:
			Enum.Tool.AXE, Enum.Tool.HOE, Enum.Tool.PICKAXE:
				stamina_cost = 4
			Enum.Tool.WATER:
				stamina_cost = 2
			Enum.Tool.FISH:
				stamina_cost = 3
			Enum.Tool.SWORD:
				stamina_cost = 1
		if stamina_cost > 0:
			Data.stamina = clamp(Data.stamina - stamina_cost, 0, Data.max_stamina)

func take_damage(amount: int):
	if god_mode:
		return
	Data.health = clamp(Data.health - amount, 0, Data.max_health)
	camera_shake(4.0, 0.15)
	hit_stop(0.08)
	if Data.health <= 0:
		pass_out()

func pass_out():
	Data.pass_out()


func _on_animation_tree_animation_started(_anim_name: StringName) -> void:
	can_move = false


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	can_move = true


func day_change_emit():
	day_change.emit()


func get_machine_coord() -> Vector2i:
	var pos = position + last_direction * 20 + Vector2(0,8)
	var coord = Vector2i(pos.x / Data.TILE_SIZE, pos.y / Data.TILE_SIZE)
	coord.x += -1 if pos.x < 0 else 0
	coord.y += -1 if pos.y < 0 else 0
	return coord * Data.TILE_SIZE + Vector2i(8,8)


func _on_step_timer_timeout() -> void:
	$Sounds/Step.play()
