class_name Deck extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	for suit in range(1, 4):
		for rank in range(0, 10):
			var card = Global.CARD_SCENE.instantiate()
			add_child(card)
			card.set_card(suit, rank)
	var card = Global.CARD_SCENE.instantiate()
	add_child(card)
	card.set_card(0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func shuffle():
	var children = get_children()
	for i in range(children.size()):
		var random_index = randi() % children.size()
		children.swap(i, random_index)
	for i in range(children.size()):
		move_child(children[i], i)
