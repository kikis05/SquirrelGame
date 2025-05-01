extends TextureButton

class_name ShopItem

@export var item_name: String = "item"
@export var description: String = "a helpful item"
@export var cost: int = 0
@export var sprite_path: String

@export var powerup_type: String = "health_increase" #change depending on what kind of powerup it is

@export var health_increase: int #should be multiple of 2
@export var speed_increase: int
@export var sword_attack_increase: int
@export var bullet_attack_increase: int
@export var bullet_distance_increase: int

@onready var itemImage = $TextureRect/Item

func _ready():
	if (sprite_path) :
		print(sprite_path)
		var img = load(sprite_path) # Replace with the actual path to your PNG file
		itemImage.texture = img
		print ("texture should be set??")

#can add other powerups here
func get_powerup_type():
	return powerup_type

func get_powerup_value():
	match powerup_type:
		"health_increase":
			return health_increase
		"speed_increase":
			return speed_increase
		"sword_attack_increase":
			return sword_attack_increase
		"bullet_attack_increase":
			return bullet_attack_increase
		"bullet_distance_increase":
			return bullet_distance_increase
	return 0
	
func get_cost():
	return cost
	
func get_description():
	return description

func get_item_name():
	return item_name
