extends CanvasLayer

@onready var text = $ShopText
@onready var cost = $Cost
@onready var item_description = $"Item Description"
@onready var powerup_description = $"Powerup Description"

@onready var items = [$ShopItem, $ShopItem2, $ShopItem3, $ShopItem4]

var player = null

var dialogues = ["Hii, p-please don't eat me! Wait, you're a squirrel?!", "How were you not eaten already? Do you also own a shop........ competitor?!", "Wow, you're still alive! Store up!", "Hey, these ants aren't so bad, but...their mama on the other hand...", "My twin sister was also brought here...it's been a while since I've seen her.", "Oh, my foot? Funny story, it was bitten off! HAHAHAhahaa...", "My only joy is swindling my customers...oh...not you of course! Hehe...", "Wanna hear me sing a song...?", "Oh my darling nut...we will be united soooon...", "...in the Queen ant's stomach, we'll have lots of room...", "Maybe I should have gone into music instead of farming...", "Oh my name?? It's Shawp Keypor.",  "I'll wait riiight here until it's safe to leave!"]
var modal_time_entered = 0
var item_view = true

var closed = true

@onready var current_item_selected = 0

func _ready():
	cost.show()
	item_description.show()
	powerup_description.show()
	text.hide()
	items[current_item_selected].deselect()
	current_item_selected = 0
	set_current_item(0)
	items[current_item_selected].select()
	#text.text = dialogues[min(time_entered, len(dialogues) - 1)]
func set_item(index, image, image_outline, item_name, cost, description, powerup_type, powerup_amount):
	items[index].set_data(image, image_outline, item_name, cost, description, powerup_type, powerup_amount)

func set_current_item(index: int):
	cost.show()
	item_description.show()
	powerup_description.show()
	cost.text = items[index].get_item_name() + ": $" +  str(items[index].get_cost())
	item_description.text  = items[index].get_description()
	powerup_description.text = get_powerup_text(items[index].get_powerup_type()) + str(items[index].get_powerup_value())
	items[index].select()
	
func reopen():
	items[current_item_selected].deselect()
	current_item_selected = 0
	set_current_item(0)
	items[current_item_selected].select()
	cost.show()
	item_description.show()
	powerup_description.show()
	#text.text = dialogues[min(modal_time_entered, len(dialogues) - 1)]
		
func set_time_entered(val):
	modal_time_entered = val
	print("modal time entered", modal_time_entered)
	text.text = dialogues[min(modal_time_entered, len(dialogues) - 1)]

func _process(delta):
	if Input.is_action_just_pressed("right") and not closed:
		items[current_item_selected].deselect()
		current_item_selected = (current_item_selected + 1) % len(items)
		set_current_item(current_item_selected)
		_sfx_click.play()
	if Input.is_action_just_pressed("left") and not closed:
		items[current_item_selected].deselect()
		current_item_selected = (current_item_selected - 1) % len(items)
		set_current_item(current_item_selected)
		_sfx_click.play()
	if Input.is_action_just_pressed("select") and not closed:
		buy()
		_sfx_click.play()

#func _on_shop_item_pressed() -> void:
	#current_item_selected = items[0]
	#print("pressed item 1")
	#shop_item_pressed(0)
#
#func _on_shop_item_2_pressed() -> void:
	#current_item_selected = items[1]
	#print("pressed item 2")
	#shop_item_pressed(1)
#
#func _on_shop_item_3_pressed() -> void:
	#current_item_selected = items[2]
	#print("pressed item 3")
	#shop_item_pressed(2)
#
#func _on_shop_item_4_pressed() -> void:
	#current_item_selected = items[3]
	#print("pressed item 4")
	#shop_item_pressed(3)

#func shop_item_pressed(item_value: int):
	#var item = ShopItem
	#match (item_value):
		#0: item = items[0]
		#1: item = items[1]
		#2: item = items[2]
		#3: item = items[3]
	#if item == null :
		#print("null item, ", item_value)
		#text.show()
		#cost.hide()
		#item_description.hide()
		#powerup_description.hide()
		#return
	##if not item_view:
	#text.hide()
	#cost.show()
	#item_description.show()
	#powerup_description.show()
	#
	#cost.text = item.get_item_name() + ": $" +  str(item.get_cost())
	#item_description.text = item.get_description()
	#powerup_description.text = get_powerup_text(item.get_powerup_type()) + str(item.get_powerup_value())
	
	
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
	buy()

			
func buy():
	print("buy was pressed!")
	print ("current item is ", items[current_item_selected])
	if player != null:
		var item = items[current_item_selected]
		if (item != null):
			if (item.get_cost() <= player.get_coins()):
				var powerup_type = item.get_powerup_type()
				var powerup_amt = item.get_powerup_value()
				print ("has coins??? cost is ", item.get_cost(), "coins are ", player.get_coins())
				if (powerup_type == "health_increase" and player.get_health() + powerup_amt > player.max_health):
					print ("maxed out health!")
					#text.show()
					cost.hide()
					#item_description.hide()
					powerup_description.hide()
					item_description.text = "I guess you *can* have too much health!"
					#text.text = "I guess you *can* have too much health!"
					return
				player.set_coins(player.get_coins() - item.get_cost());
				
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
				#text.show()
				cost.hide()
				#item_description.hide()
				powerup_description.hide()
				item_description.text = "Outta money? Come back next time!"
				#text.text = "Outta money? Come back next time!"
