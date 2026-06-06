@tool
extends StaticBody2D

@export_range(0,3,1) var size: int:
	set(value):
		size = value
		_update_state()

@export_enum('Bush', 'Rock') var style: int:
	set(value):
		style = value
		_update_state()

@export var random: bool
@export_tool_button('Randomize', "Callable") var randomizer = randomize_object


func _ready() -> void:
	if random:
		randomize()
		if has_node("Sprite2D"):
			size = randi_range(0, $Sprite2D.hframes - 1)
		style = [0,1].pick_random()
	
	_update_state()


func _update_state():
	if is_node_ready():
		$Sprite2D.frame_coords = Vector2i(size, style)
		$CollisionShape2D.set_deferred("disabled", size < 2)
		z_index = -1 if size < 2 else 0


func interact(_player):
	pass


func randomize_object():
	randomize()
	if is_node_ready():
		size = randi_range(0, $Sprite2D.hframes - 1)
	style = [0,1].pick_random()
