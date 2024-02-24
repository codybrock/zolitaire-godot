class_name Table extends Node2D

@onready var deck: Deck = $Deck
@onready var cell: Cell = $Cell

var glow_card: Card = null
var float_card = null
var float_origin = null


# Called when the node enters the scene tree for the first time.
func _ready():
	# gen_cards(15)
	gen_tableau(9)
	cell.set_variant(Cell.CellVariant.TABLEAU)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_top_card_mouse():
	var card_group = get_tree().get_nodes_in_group(Global.CARD_GROUP)
	var overlaps: Array = []
	for card in card_group:
		if card.mouse_over:
			overlaps.append(card)
	if overlaps.size() == 0:
		return null
	return overlaps[-1]


func get_top_card_float_overlap():
	if float_card == null:
		return null
	return float_card.get_top_card_overlap()


func _unhandled_input(event):
	# DEBUG INFO RIGHT CLICK
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.is_pressed():
			glow_card = get_top_card_mouse()
			prints("top card:", glow_card.name, "stack:", glow_card.stacked_count())
			glow_card.card_sprite.modulate = Color.YELLOW.lightened(.2)
			prints("valid_stacked:", glow_card.is_valid_stacked())
		elif event.is_released():
			glow_card.card_sprite.modulate = Color.WHITE
			glow_card = null

	if float_card == null:
		grounded_input(event)
	else:
		floating_input(event)


func grounded_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var top_card: Card = get_top_card_mouse()
			if top_card == null:
				return
			if top_card.is_valid_stacked():
				# TODO: pickup restrictions. check up the line?
				float_card = top_card
				float_origin = float_card.get_parent()
				float_card.unstack()
				float_card.start_floating()
				float_card.start_shadows()


func floating_input(event):
	# drag along with mouse
	if event is InputEventMouseMotion:
		float_card.position += event.relative
	# drop, end floating and animate descent
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_released()
	):
		var top_card = get_top_card_float_overlap()
		if top_card and top_card.allow_stack(float_card):
			top_card.stack_card(float_card)
		elif float_origin.allow_stack(float_card):
			float_origin.stack_card(float_card)
		else:
			printerr("invalid float origin")
			get_tree().quit()
		float_card.stop_floating()
		prints("stop floating:", float_card.name)
		float_card = null
		float_origin = null


# DEBUG SETUP FUNCTIONS
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
			cell.stack_card(card)
		else:
			last.stack_card(card)
		card.set_card(rank, suit)
		last = card
		prints("created card:", card.name, "rank:", card.rank, "suit:", card.suit)
