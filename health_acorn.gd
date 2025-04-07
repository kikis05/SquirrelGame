extends Panel

@onready var sprite = $Sprite2D

func update(fraction: int): #should be 0, 1, or 2
	if (fraction != 0 and fraction != 1 and fraction != 2):
		fraction = 2 #instead can add error handling!!
	sprite.frame = fraction
