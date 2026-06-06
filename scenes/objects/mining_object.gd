class_name MiningObject extends StaticBody2D

enum OreType { STONE, GOLD, SILVER, PLATINUM, DIAMOND, RUBY, SAPPHIRE, EMERALD }

@export var ore_type: OreType
@export var health: int = 3

var ORE_DATA = {
	OreType.STONE: {"color": Color.GRAY, "item": Enum.Item.STONE, "amount": 3},
	OreType.GOLD: {"color": Color.GOLD, "item": Enum.Item.GOLD, "amount": 1},
	OreType.SILVER: {"color": Color.LIGHT_GRAY, "item": Enum.Item.SILVER, "amount": 1},
	OreType.PLATINUM: {"color": Color.CYAN, "item": Enum.Item.PLATINUM, "amount": 1},
	OreType.DIAMOND: {"color": Color.WHITE, "item": Enum.Item.DIAMOND, "amount": 1},
	OreType.RUBY: {"color": Color.RED, "item": Enum.Item.RUBY, "amount": 1},
	OreType.SAPPHIRE: {"color": Color.BLUE, "item": Enum.Item.SAPPHIRE, "amount": 1},
	OreType.EMERALD: {"color": Color.GREEN, "item": Enum.Item.EMERALD, "amount": 1},
}

func _ready():
	add_to_group("Objects")
	var config = ORE_DATA.get(ore_type, ORE_DATA[OreType.STONE])
	
	var flash_sprite = get_node_or_null("FlashSprite2D")
	if flash_sprite:
		flash_sprite.modulate = config["color"]
		
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		sprite.modulate = config["color"]

func hit(tool: Enum.Tool, _dir: Vector2 = Vector2.ZERO):
	if tool == Enum.Tool.PICKAXE:
		health -= 1
		$FlashSprite2D.flash()
		
		# Feedback on hit
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.camera_shake(1.5, 0.1)
			if player.has_node("Sounds/Axe"):
				player.get_node("Sounds/Axe").play()
			
		if health <= 0:
			die()

func die():
	var config = ORE_DATA[ore_type]
	Data.change_item(config["item"], config["amount"])
	queue_free()

func interact(_player):
	pass
