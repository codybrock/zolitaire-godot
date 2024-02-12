extends Control

@onready var container = $VBoxContainer
var cards = []


# Called when the node enters the scene tree for the first time.
func _ready():
	for card in get_tree().get_nodes_in_group("card_group"):
		cards.append(card)


# Called every frame. 'delta' is the elapsed time since the previous frame.
var last = 0


func _process(delta):
	pass
# 	if int((delta - last) % 1000.0) != 0:
# 		return
# 	print("update")
# 	for card in cards:
# 		var label = Label.new()
# 		label.text = card.name + ": " + "shadow" if card.shadow_active else "none"
# 		container.add_child(label)
