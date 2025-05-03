extends shop

func _ready():
	modal.set_item(0, 
				   "res://art/shop_items/SunflowerSeed.png",
				   "Sunflower Seed",
					5,
				   "a small but reasonable energy boost!" ,
				   "speed_increase",
					20 )
	modal.set_item(1, 
				   "res://art/shop_items/HalfAcorn.png",
				   "half-eaten acorn",
					10,
				   "you can never have too much health!" ,
				   "health_increase",
					1 )
	modal.set_item(2, 
				   "res://art/shop_items/SpicySap.png",
				   "sap",
					7,
				   "spicy sap! tasty and painful" ,
				   "bullet_attack_increase",
					3 )
	modal.set_item(3, 
				   "res://art/shop_items/Thorn.png",
				   "thorn",
					5,
				   "Makes your sword look cool!" ,
				   "sword_attack_increase",
					5 )
	modal.hide()
	pass
