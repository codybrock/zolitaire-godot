extends Node2D
const CARD_SCENE = preload("res://scenes/card/card.tscn")

var glow_card: Card = null

# Called when the node enters the scene tree for the first time.
func _ready():
	gen_cards(15)
	
	#var view_dim = get_viewport().get_visible_rect().size
	#
	#var card1: Card = CARD_SCENE.instantiate()
	#add_child(card1)
	#card1.position = view_dim * 0.25
	#card1.name = "Card_01"
	#card1.set_card(1, 1)
	##card1.rank = 1
	##card1.suit = 1
	###card1.card_sprite.frame_coords.x = 1
	###card1.card_sprite.frame_coords.y = 1
	#
	#var card2: Card  = CARD_SCENE.instantiate()
	#add_child(card2)
	#card2.position = view_dim * 0.5
	#card2.name = "Card_02"
	#card2.set_card(2, 2)
	#
	#var card3: Card  = CARD_SCENE.instantiate()
	#add_child(card3)
	#card3.position = view_dim * 0.75
	#card3.name = "Card_03"
	#card3.set_card(3, 3)
	#
	#
	#card2.stack_card(card1)
	#card3.stack_card(card2)


func gen_cards(quantity):
	var view_dim = get_viewport().get_visible_rect().size
	var last = null
	for i in quantity:
		var rank = randi() % 9 + 1
		var suit = randi() % 3 + 1
		var card: Card = CARD_SCENE.instantiate()
		add_child(card)
		if last == null:
			card.position.x = view_dim.x * 0.5
			card.position.y = view_dim.y * 0.15
		else:
			last.stack_card(card)
		card.set_card(rank, suit)
		last = card
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_top_card_mouse():
	var card_group = get_tree().get_nodes_in_group("card_group")
	var overlaps: Array = []
	for card in card_group:
		if card.mouse_over:
			#prints("overlapping:", card.name)
			overlaps.append(card)
	if overlaps.size() == 0:
		return null
	return overlaps[-1]


#func get_top_card_overlap(float_card):
	#return float_card.get_top_card_overlap()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var top_card: Card = get_top_card_mouse()
			if top_card == null:
				return
			if top_card.get_parent() is Card:
				top_card.get_parent().unstack_card()
			top_card.start_floating()
	
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			glow_card = get_top_card_mouse()
			prints("top card:", glow_card.name, "stack:", glow_card.stacked_count())
			glow_card.card_sprite.modulate = Color.YELLOW.lightened(.2)
		elif event.is_released():
			glow_card.card_sprite.modulate = Color.WHITE
			glow_card = null
