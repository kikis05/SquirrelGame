extends CanvasLayer

@onready var text = $Label
var dialogues = ["Another Squirrel?! You better make it quick before they spot us!"]

func _ready():
	text.text = dialogues[0]
