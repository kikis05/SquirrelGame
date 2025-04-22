extends HBoxContainer

@onready var coins = $Label

func update_coins(value):
	coins.text = str(value)
