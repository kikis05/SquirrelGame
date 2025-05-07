extends shop

func _ready():
	modal.set_item(0, 
				   "res://art/shop_items/Blueberry.png",
				"res://art/shop_items/BlueberryOutline.png",
				   "Blueberry",
					10,
				   "I can just taste the vitamin D! Or B..." ,
				   "speed_increase",
					50 )
	modal.set_item(1, 
				   "res://art/shop_items/FullAcorn.png",
				"res://art/shop_items/FullAcornOutline.png",
				   "(not eaten)acorn",
					20,
				   "So precious these are!" ,
				   "health_increase",
					2 )
	modal.set_item(2, 
				   "res://art/shop_items/Pebbles.png",
				 "res://art/shop_items/PebblesOutline.png",
				   "pebbles",
					15,
				   "for sticking in sap, or skipping over water!" ,
				   "bullet_distance_increase",
					50 )
	modal.set_item(3, 
				   "res://art/shop_items/SpicySap.png",
				"res://art/shop_items/SpicySapOutline.png",
				   "spicier sap!",
					10,
				   "have some water with that." ,
				   "bullet_attack_increase",
					4 )
	modal.hide()
	pass
