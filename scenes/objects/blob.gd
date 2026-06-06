extends CharacterBody2D

var direction: Vector2
var speed := 20
var push_distance := 130
var push_direction: Vector2
var health := 3:
	set(value):
		health = value
		if health <= 0:
			death()
var plant_target: StaticBody2D
var active: bool = true

@onready var player = get_tree().get_first_node_in_group('Player')

func _ready() -> void:
	add_to_group("Objects")
	add_to_group("Blobs")


func setup(start_pos, target, parent):
	position = start_pos
	parent.add_child(self)
	plant_target = target


func _physics_process(_delta: float) -> void:
	var target_pos = Vector2.ZERO
	var has_target = false
	
	if plant_target and is_instance_valid(plant_target):
		target_pos = plant_target.position
		has_target = true
	elif player and is_instance_valid(player):
		target_pos = player.position
		has_target = true
		
	if has_target:
		direction = (target_pos - position).normalized()
		velocity = direction * speed + push_direction
		move_and_slide()
		
		if player and is_instance_valid(player) and position.distance_to(player.position) < 12 and active:
			if player.has_method("take_damage"):
				player.take_damage(15)
				active = false
				death()
				return
				
		if plant_target and is_instance_valid(plant_target) and position.distance_to(plant_target.position) < 10 and active:
			plant_target.damage()
			active = false
			death()
	else:
		death()


func push(dir = Vector2.ZERO):
	var tween = get_tree().create_tween()
	var target_dir = dir if dir else (player.position - position).normalized()
	var target =  target_dir * -1 * push_distance
	tween.tween_property(self, "push_direction", target, 0.1)
	tween.tween_property(self, "push_direction", Vector2.ZERO, 0.2)


func death():
	speed = 0
	$AnimationPlayer.current_animation = 'explode'


func hit(tool: Enum.Tool, dir = Vector2.ZERO):
	if tool == Enum.Tool.SWORD:
		$FlashSprite2D.flash()
		push(dir)
		health -= 1
		if player:
			player.hit_stop(0.05)
			player.camera_shake(3.0, 0.1)
