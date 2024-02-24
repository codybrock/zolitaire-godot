class_name Cell extends Node2D

enum CellVariant { TABLEAU, FREECELL, FOUNDATION, ACE, SUPERACE }

@onready var cell_sprite: Sprite2D = $CellSprite
@onready var cell_area: Area2D = $CellArea2D

@onready var variant: CellVariant

@onready var stacked_card: Card = null


# Called when the node enters the scene tree for the first time.
func _ready():
	set_variant(5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_variant(cell_variant: CellVariant):
	variant = cell_variant
	cell_sprite.frame = variant


func get_stack_array():
	var array: Array = [self]
	if stacked_card:
		array.append_array(stacked_card.get_stack_array())
	return array


func allow_stack(card: Card):
	if variant == CellVariant.TABLEAU:
		return tableau_can_stack(card)
	elif variant == CellVariant.FOUNDATION:
		return foundation_can_stack(card)
	elif variant == CellVariant.FREECELL:
		return freecell_can_stack(card)
	elif variant == CellVariant.ACE:
		return ace_can_stack(card)
	else:
		printerr("Cell variant not found")
		return false


func tableau_can_stack(card: Card):
	# different suit, if stacking rank -1 and no aces
	if stacked_card == null:
		return true

	if card.rank == 0 or card.suit == 0:
		return false

	var stack = get_stack_array()
	if card.suit == stack[-1].suit:
		return false
	if card.rank == stack[-1].rank - 1:
		return true
	else:
		return false


func foundation_can_stack(card: Card):
	# if empty, start with 1. else, if same suit and rank +1
	if card.suit == 0:
		return false
	if stacked_card == null:
		if card.rank == 1:
			return true
		else:
			return false
	var stack = get_stack_array()
	if card.suit != stack[-1].suit:
		return false
	elif card.rank == stack[-1].rank + 1:
		return true
	else:
		return false


func freecell_can_stack(card: Card):
	# only room for one card (any card)
	if stacked_card == null:
		return true
	else:
		return false


func ace_can_stack(card: Card):
	# player can't stack
	return false


func stack_card(card: Card):
	stacked_card = card
	card.reparent(self)
	stacked_card.stack_base = self

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card, "position", Vector2.ZERO, .05)


func unstack_card():
	var card = stacked_card
	card.stack_base = null
	stacked_card = null
	card.reparent(get_parent())
