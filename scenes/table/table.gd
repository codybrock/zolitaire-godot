extends Node2D

@onready var deck: Deck = $Deck

var glow_card: Card = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# print("_ready")
	# # deck.init()
	# # print("deck init")
	# deck.shuffle()
	# print("deck shuffle")

	# var cells = []
	# for i in 8:
	# 	prints("gen cell:", i)
	# 	var cell = $Cell.instantiate()
	# 	print("cell:", cell)
	# 	# cell.position = Vector2(100 + i * 100, 100)
	# 	add_child(cell)
	# 	cells.append(cell)
	# print("cells:", cells)

	# var viewport_size = get_viewport().get_visible_rect().size
	# var count = cells.size()
	# var spacing = viewport_size.x / (count + 1)

	# for i in range(count):
	# 	var node = cells[i]
	# 	node.position.x = spacing * (i + 1)
	# 	node.position.y = viewport_size.y / 2

	# gen_cards(15)
	gen_tableau(9)

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
		var card: Card = Global.CARD_SCENE.instantiate()
		add_child(card)
		if last == null:
			card.position.x = view_dim.x * 0.5
			card.position.y = view_dim.y * 0.15
		else:
			last.stack_card(card)
		card.set_card(rank, suit)
		last = card


func gen_tableau(quantity):
	if quantity > 9:
		quantity = 9
	var view_dim = get_viewport().get_visible_rect().size
	var last = null
	for i in quantity:
		var rank = quantity - i
		var suit = i % 3 + 1
		var card: Card = Global.CARD_SCENE.instantiate()
		add_child(card)
		card.name = "Card_" + str(rank) + "_" + str(suit)
		if last == null:
			card.position.x = view_dim.x * 0.5
			card.position.y = view_dim.y * 0.15
		else:
			last.stack_card(card)
		card.set_card(rank, suit)
		last = card
		prints("created card:", card.name, "rank:", card.rank, "suit:", card.suit)


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
			if top_card.is_valid_stacked():
				if top_card.get_parent() is Card:
					top_card.get_parent().unstack_card()
				top_card.start_floating()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			glow_card = get_top_card_mouse()
			prints("top card:", glow_card.name, "stack:", glow_card.stacked_count())
			glow_card.card_sprite.modulate = Color.YELLOW.lightened(.2)
			prints("valid_stacked:", glow_card.is_valid_stacked())
		elif event.is_released():
			glow_card.card_sprite.modulate = Color.WHITE
			glow_card = null
