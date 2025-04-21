extends TextureButton

class_name ShopItem

@export var item_name: String = "item"
@export var description: String = "a helpful item"
@export var sprite: Sprite2D 

@export var powerup_type: String = "health_increase" #change depending on what kind of powerup it is

@export var health_increase: int #should be multiple of 2
@export var speed_increase: int
@export var sword_attack_increase: int
@export var bullet_attack_increase: int
@export var bullet_distance_increase: int

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
