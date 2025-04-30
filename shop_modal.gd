extends CanvasLayer

@onready var text = $ShopText
@onready var cost = $Cost
@onready var item_description = $"Item Description"
@onready var powerup_description = $"Powerup Description"

@onready var item1 = $ShopItem
@onready var item2 = $ShopItem2
@onready var item3 = $ShopItem3
@onready var item4 = $ShopItem4

var player = null

var dialogues = ["Another Squirrel?! You better make it quick before they spot us!"]

var item_view = false

var current_item_selected = null

func _ready():
	cost.hide()
	item_description.hide()
	powerup_description.hide()
	text.text = dialogues[0]

func _on_shop_item_pressed() -> void:
	current_item_selected = item1
	print("pressed item 1")
	shop_item_pressed(0)

func _on_shop_item_2_pressed() -> void:
	current_item_selected = item2
	print("pressed item 2")
	shop_item_pressed(1)


func _on_shop_item_3_pressed() -> void:
	current_item_selected = item3
	print("pressed item 3")
	shop_item_pressed(2)

func _on_shop_item_4_pressed() -> void:
	current_item_selected = item4
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


func _on_buy_pressed() -> void:
	print("buy was pressed!")
	print ("current item is ", current_item_selected)
	if player != null:
		if (current_item_selected != null):
			if (current_item_selected.get_cost() <= player.get_coins()):
				var powerup_type = current_item_selected.get_powerup_type()
				var powerup_amt = current_item_selected.get_powerup_value()
				print ("has coins??? cost is ", current_item_selected.get_cost(), "coins are ", player.get_coins())
				if (powerup_type == "health_increase" and player.get_health() + powerup_amt > player.max_health):
					print ("maxed out health!")
					text.show()
					cost.hide()
					item_description.hide()
					powerup_description.hide()
					text.text = "I guess you *can* have too much health!"
					return
				player.set_coins(player.get_coins() - current_item_selected.get_cost());
				
				match(powerup_type):
					"health_increase":
						player.set_health(player.get_health() + powerup_amt)
					"speed_increase":
						player.set_speed(player.speed + powerup_amt)
					"sword_attack_increase":
						player.set_sword_attack(player.get_sword_attack() + powerup_amt)
					"bullet_attack_increase":
						player.set_gun_attack(player.get_gun_attack() + powerup_amt)
					"bullet_distance_increase":
						player.set_gun_speed(player.get_gun_speedk() + powerup_amt)
			else:
				print ("no money!")
				text.show()
				cost.hide()
				item_description.hide()
				powerup_description.hide()
				text.text = "Outa money? Come back next time!"
			
