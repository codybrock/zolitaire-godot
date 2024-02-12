class_name Card extends Node2D

const WIDTH = 64
const HEIGHT = 96
const STACK_OFFSET_VECTOR = Vector2(0, 16)
const FLOAT_OFFSET_VECTOR = Vector2(5, -5)
const CARD_GROUP = "card_group"
const SHADOW_SCENE = preload("res://scenes/card/shadow_sprite.tscn")

@onready var card_sprite: Sprite2D = $CardSprite
@onready var card_area: Area2D = $CardArea2D
@onready var overlap_area: Area2D = $OverlapArea2D
@onready var shadow_group: CanvasGroup = $ShadowGroup
@onready var valid_stack_indicator: ColorRect = $ValidStack

@onready var suit = 0
@onready var rank = 0

var mouse_over: bool = false
var floating: bool = false
var stacked_card: Card = null
var shadow_active: bool = false

var glow_card: Card = null


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(CARD_GROUP)
	valid_stack_indicator.color = Color.GREEN
	set_card(0, 0)
	#
	#card_sprite.frame_coords.x = rank
	#card_sprite.frame_coords.y = suit


func set_card(card_rank, card_suit):
	rank = card_rank
	suit = card_suit
	card_sprite.frame_coords.x = card_rank
	card_sprite.frame_coords.y = card_suit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$LocalPos.text = str(position.x, ",", position.y)
	$GlobalPos.text = str(global_position.x, ",", global_position.y)
	#if mouse_over:
	#card_sprite.modulate = Color(1.25, 1.25, 1.25)
	#else:
	#card_sprite.modulate = Color.WHITE

	if is_valid_stacked():
		valid_stack_indicator.color = Color.GREEN
	else:
		valid_stack_indicator.color = Color.RED


func _on_area_2d_mouse_entered():
	mouse_over = true


func _on_area_2d_mouse_exited():
	mouse_over = false


func _unhandled_input(event):
	# card currently held?
	if floating:
		input_floating(event)
	# Mouse interactions
	#elif mouse_over:
	## Left click, start float
	##get_top_card()
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
	#if event.is_pressed() and not floating:
	##if not recursive_check_stacked():
	#while get_parent() is Card:
	#reparent(get_parent().get_parent())
	#start_shadows()
	#start_floating()


func input_floating(event):
	if get_parent() is Card:
		return
	#var over_areas = overlap_area.get_overlapping_areas()
	#print(over_areas)
	#for area in over_areas:
	#if area.get_parent() != self:
	#if area.get_parent().can_stack(self):
	#area.get_parent().card_sprite.self_modulate = Color.GOLD
	#else:
	#area.get_parent().card_sprite.self_modulate = Color.RED

	# drag along with mouse
	if event is InputEventMouseMotion:
		position += event.relative
	# drop, end floating and animate descent
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_released()
	):
		stop_floating()
		var top_card = get_top_card_overlap()
		if top_card and not top_card.stacked_card:
			top_card.stack_card(self)


func get_top_card_overlap():
	var overlaps = overlap_area.get_overlapping_areas()
	var overlapped_cards = []
	for area in overlaps:
		overlapped_cards.append(area.get_parent())

	var top_card = null
	var card_group = get_tree().get_nodes_in_group(CARD_GROUP)
	for card in card_group:
		if card != self and card in overlapped_cards and !(card in get_stack_array()):
			top_card = card
	if top_card:
		prints("overlap top card:", top_card.name)
	return top_card


func start_floating(delay = 0.0):
	if floating:
		return
	if stacked_card != null:
		stacked_card.start_floating(0.02)

	get_parent().move_child(self, -1)
	#origin = get_parent()

	start_shadows()
	var tween = create_tween()
	tween.set_parallel()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(card_sprite, "position", Vector2(5, -5), .25 + delay)
	floating = true
	#tween.tween_property(shadow_sprite, "position", Vector2(-5, 5), .25)


func stop_floating(revert: bool = false):
	if not floating:
		return
	if stacked_card != null:
		stacked_card.stop_floating(revert)
	#if origin and origin is Card and revert:
	#origin.stack_card(self)
	#self.stop_floating
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card_sprite, "position", Vector2(0, 0), .05)
	if !(get_parent() is Card):
		tween.connect("finished", stop_shadows)
	floating = false


func is_valid_stacked():
	if not stacked_card:
		return true
	if stacked_card.suit != suit and stacked_card.rank == rank - 1 and stacked_card.rank != 0:
		if stacked_card.is_valid_stacked():
			return true
	return false


func stacked_count():
	if not stacked_card:
		return 0
	return stacked_card.stacked_count() + 1


func can_stack(card: Card) -> bool:
	# rules:
	#  not already stacked
	#  different suit
	#  rank 1 lower
	#  not "ace"
	if not stacked_card:
		if card.suit != suit:
			if card.rank == rank - 1 and card.rank != 0:
				return true
	return false


func stack_card(card: Card):
	stacked_card = card
	card.reparent(self)
	#stacked_card.position = STACK_OFFSET_VECTOR

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(card, "position", STACK_OFFSET_VECTOR, .05)


func unstack_card() -> Card:
	var card = stacked_card
	stacked_card = null
	while card.get_parent() is Card:
		card.reparent(card.get_parent().get_parent())
	return card


func start_shadows():
	if shadow_active or get_parent() is Card:
		return
	shadow_active = true
	shadow_group.add_child(SHADOW_SCENE.instantiate())
	for i in stacked_count():
		var shadow = SHADOW_SCENE.instantiate()
		shadow.position = STACK_OFFSET_VECTOR * (i + 1)
		shadow_group.add_child(shadow)
	shadow_group.visible = true
	prints(name, "start shadows")
	prints("  parent was card:", get_parent() is Card)
	prints("  stacked count:", stacked_count())


func stop_shadows():
	if not shadow_active or get_parent() is Card:
		return
	#await get_tree().create_timer(.25).timeout
	shadow_group.visible = false
	for shadow in shadow_group.get_children():
		shadow.queue_free()
	shadow_active = false


func get_stack_array():
	var array: Array = [self]
	if stacked_card:
		array.append_array(stacked_card.get_stack_array())
	return array
