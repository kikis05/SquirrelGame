extends CanvasLayer

@onready var text = $ShopText
var dialogues = ["Another Squirrel?! You better make it quick before they spot us!"]

func _ready():
	text.text = dialogues[0]
