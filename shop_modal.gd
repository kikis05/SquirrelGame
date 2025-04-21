extends CanvasLayer

@onready var text = $ShopText
@onready var cost = $Cost
@onready var item_description = $"Item Description"
@onready var powerup_description = $"Powerup Description"

@onready var item1 = $ShopItem
@onready var item2 = $ShopItem2
@onready var item3 = $ShopItem3
@onready var item4 = $ShopItem4

var dialogues = ["Another Squirrel?! You better make it quick before they spot us!"]

var item_view = false

func _ready():
	cost.hide()
	item_description.hide()
	powerup_description.hide()
	text.text = dialogues[0]



func _on_shop_item_pressed() -> void:
	print("pressed item 1")
	shop_item_pressed(0)

func _on_shop_item_2_pressed() -> void:
	print("pressed item 2")
	shop_item_pressed(1)


func _on_shop_item_3_pressed() -> void:
	print("pressed item 3")
	shop_item_pressed(2)

func _on_shop_item_4_pressed() -> void:
	print("pressed item 4")
	shop_item_pressed(3)

func shop_item_pressed(item_value: int):
	var item = ShopItem
	match (item_value):
		0: item = item1
		1: item = item2
		2: item = item3
		3: item = item4
	if item == null :
		print("null item, ", item_value)
		text.show()
		cost.hide()
		item_description.hide()
		powerup_description.hide()
		return
	#if not item_view:
	text.hide()
	cost.show()
	item_description.show()
	powerup_description.show()
	
	cost.text = item.get_item_name() + ": $" +  str(item.get_cost())
	item_description.text = item.get_description()
	powerup_description.text = get_powerup_text(item.get_powerup_type()) + str(item.get_powerup_value())
	
	
func get_powerup_text(powerup_type: String):
	match(powerup_type):
		"health_increase":
			return "health + "
		"speed_increase":
			return "speed + "
		"sword_attack_increase":
			return "sword attack + "
		"bullet_attack_increase":
			return "sap shooter attack + "
		"bullet_distance_increase":
			return "sap shooter range + "
			
	return "something??? + "


func _on_test_button_pressed() -> void:
	print("button pressed")
	shop_item_pressed(0)
