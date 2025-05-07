extends TextureButton

class_name ShopItem

@export var item_name: String = "item"
@export var description: String = "a helpful item"
@export var cost: int = 0

@export var sprite_path: String
var img
@export var sprite_outline_path: String
var img_outline

@export var powerup_type: String = "health_increase" #change depending on what kind of powerup it is

var is_selected = false

#@export var health_increase: int #should be multiple of 2
#@export var speed_increase: int
#@export var sword_attack_increase: int
#@export var bullet_attack_increase: int
#@export var bullet_distance_increase: int

@export var powerup_value: int

@onready var itemImage = $TextureRect/Item

func set_data(image_,image_outline, name_, cost_, description_, powerup_type_, powerup_amount_):
	sprite_path = image_
	sprite_outline_path = image_outline
	print(sprite_path)
	img = load(sprite_path) # Replace with the actual path to your PNG file
	img_outline = load(sprite_outline_path)
	itemImage.texture = img
	print ("texture should be set??")
	item_name = name_
	cost = cost_
	description = description_
	powerup_type = powerup_type_
	powerup_value = powerup_amount_
	
func _process(delta):
	#if is_selected:
		#var img = load(sprite_outline_path) # Replace with the actual path to your PNG file
		#itemImage.texture = img
	#else:
		#var img = load(sprite_path)
		#itemImage.texture = img
	pass
		
func select():
	is_selected = true
	itemImage.texture = img_outline
func deselect():
	is_selected = false
	itemImage.texture = img
	
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
	#match powerup_type:
		#"health_increase":
			#return health_increase
		#"speed_increase":
			#return speed_increase
		#"sword_attack_increase":
			#return sword_attack_increase
		#"bullet_attack_increase":
			#return bullet_attack_increase
		#"bullet_distance_increase":
			#return bullet_distance_increase
	return powerup_value
	
func get_cost():
	return cost
	
func get_description():
	return description

func get_item_name():
	return item_name
