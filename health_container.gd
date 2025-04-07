extends HBoxContainer

@onready var AcornGUIClass = preload("res://health_acorn.tscn")

func setMaxAcorns(max: int):
	for i in range(max):
		var acorn = AcornGUIClass.instantiate()
		add_child(acorn)
		
func updateHealth(current_health: int):
	var acorns = get_children()
	var health = len(acorns)
	
	for i in range (health):
		if (i < (current_health / 2)):
			acorns[i].update(0)
		else: 
			if (current_health % 2 == 1 and i == current_health / 2):
				acorns[i].update(1)
			else:
				acorns[i].update(2)
		
	
